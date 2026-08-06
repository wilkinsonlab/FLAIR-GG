# MCP tools

This folder is the tool catalogue for the MCP (Model Context Protocol)
endpoint at `POST /flair-gg-vp-server/mcp` (`app/controllers/mcp_routes.rb`).
Every tool an MCP client (an LLM agent, Claude.ai's connector, Claude Code,
...) can call is one file here — nothing about a tool's name, description,
or input schema lives in the routing code. `mcp_routes.rb` only knows how to
list `MCP_TOOL_CLASSES` and dispatch a call to whichever one was named; it
has no idea what any individual tool actually does.

The same data is also readable by a human, without an MCP client, at
`GET /flair-gg-vp-server/mcp` in a browser — that page is generated
directly from this folder too, so it can't drift from what the server
actually offers. Share that link, not this file, with someone who just
wants to see what's available.

## The two shapes of tool in here

### 1. A plain, standalone tool

`keyword_search.rb` and `sparql_query.rb` are the simplest shape: a class
under `McpTools` with three constants and one class method.

```ruby
module McpTools
  class MyTool
    NAME = 'my_tool'.freeze

    DESCRIPTION = 'One paragraph, written for the LLM calling this tool, ' \
                  'not for a human reading the source - explain what it ' \
                  'does, when to use it instead of some other tool, and ' \
                  'anything surprising about its output.'.freeze

    INPUT_SCHEMA = {
      type: 'object',
      properties: {
        some_arg: { type: 'string', description: '...' }
      },
      required: ['some_arg']
    }.freeze

    # @param arguments [Hash] string-keyed, exactly what the MCP client sent
    # @return [Array<Hash>] the MCP `content` array - almost always a single
    #   `{ type: 'text', text: '...' }` block, `text` being a JSON string
    def self.call(arguments)
      # ... do the work ...
      [{ type: 'text', text: some_result.to_json }]
    end
  end
end
```

Register it by adding the class to `MCP_TOOL_CLASSES` in
`app/controllers/mcp_routes.rb`. That's the only other file that needs to
change.

**Errors:** don't rescue inside `call` unless you're turning one failure
mode into a more specific message. The dispatcher wraps any exception a
tool raises into a JSON-RPC error (`-32000`, `e.message`) automatically —
raise `ArgumentError` or let a real exception (a broken query, a failed
HTTP call) propagate, and it becomes a clean error response instead of a
500.

### 2. One data service type, via `RawServiceTypeCall`

This is the shape for "execute the raw data call against every live
provider of service type X" — `iucn_endangerment_status.rb` is the first
and, at time of writing, only example.

**Background this shape depends on:** FLAIR-GG data services are FDP
(FAIR Data Point) `dcat:DataService` entries, each tagged with a `dc:type`
ontology URI identifying what *kind* of service it is (e.g.
`...flair-gg-application-ontology.owl#IUCN_categorization`). It's an
unwritten but real FLAIR-GG convention that every provider registered
under the same `dc:type` implements the *same interface* — same shape of
request in, same shape of data out — even though the providers themselves
are independently run (different institutions, different hosts). That's
what makes "one MCP tool per service type" a coherent idea at all: the
tool doesn't need to know anything about any individual provider, just the
type they all agree to implement.

`RawServiceTypeCall` (`raw_service_type_call.rb`) is a base class that does
the actual work once:

1. `VP#retrieve_sevices(termuri:)` — the VP's own service-discovery search
   (the same one backing the human-facing `GET /retrieve-services` route)
   — finds every currently-live provider registered under a given
   `dc:type` URI. **Use this, not a hand-written SPARQL query.** Providers
   come, go, and occasionally move host entirely (the ongoing
   `linkeddata.systems` migration is a live example) — the search API
   tracks that automatically; a hardcoded endpoint list or bespoke query
   would silently go stale.
2. For each provider found, issues a plain `GET` directly against that
   provider's real endpoint via `Service.execute_get` and returns the raw
   response body.
3. One provider being down or mid-migration produces `{"error": "..."}`
   for that provider's key in the result, not a failure of the whole
   call — the other providers still come back normally.

**Deliberately skipped:** `VP#execute_data_services_api`'s LDP-upload /
notebook-URL wiring, which is what the human UI and the ComfyUI workflow
integration use. That path exists to hand a batch of results to the
ComfyUI/Jupyter side via a temporary store — an MCP caller has no use for
that; it wants the data back in the JSON-RPC response, directly, right
now.

A concrete tool built on this base is a handful of constants and nothing
else:

```ruby
require_relative 'raw_service_type_call'

module McpTools
  class MyServiceTypeStatus < RawServiceTypeCall
    NAME = 'my_service_type_status'.freeze

    SERVICE_TYPE_URI = 'https://example.org/ontology#MyServiceType'.freeze

    SUMMARY = <<~SUMMARY.freeze
      What this fetches, in LLM-facing language, plus a note that it's a
      fixed lookup with no parameters and that results are keyed by
      provider endpoint URL.
    SUMMARY

    DESCRIPTION = build_description(
      summary: SUMMARY,
      reference_notebook_filename: 'my_notebook.ipynb'
    ).freeze
  end
end
```

`INPUT_SCHEMA` and `call` are inherited — don't redefine them.

### Point at the reference notebook

Almost every service type here has a corresponding FLAIR-GG-Analytics
Jupyter notebook showing how that data is normally analyzed (the notebook
this tool's own port was based on, if it came from one). Pass its filename
as `reference_notebook_filename:` to `build_description` — the default
shape, not an opt-in extra — and it appends a pointer to the notebook's
**raw** URL (fetchable JSON an LLM can actually read) to the description.

Use the raw-content URL
(`https://raw.githubusercontent.com/wilkinsonlab/FLAIR-GG-Analytics/main/content/FLAIR-GG/<file>.ipynb`,
which `REFERENCE_NOTEBOOK_BASE_URL` builds from just the filename), **not**
`VP#notebook_url`'s JupyterLite viewer link
(`.../lab/index.html?path=...`) — that one's an interactive HTML app meant
for a human to click, not something an LLM fetching it as a tool hint can
parse as notebook content. Whether the calling LLM actually fetches it
depends on the MCP *client* having its own web-fetch tool available — this
server doesn't serve notebook content itself, only points at where it
lives.

Omit `reference_notebook_filename:` (or call `build_description` with just
`summary:`) only for a tool that genuinely has no corresponding notebook.

**The `require_relative 'raw_service_type_call'` line at the top is not
optional.** This folder is loaded via `require_rel` (see
`app/controllers/mcp_routes.rb`), which requires every file in the
directory in alphabetical order with no dependency resolution or retry —
unlike `lib/vp.rb`'s use of `require_all`/`require_rel` elsewhere in this
codebase, this gem version doesn't retry a file that failed because a
constant it needs isn't defined yet. Since `class MyServiceTypeStatus <
RawServiceTypeCall` resolves its superclass at load time, not call time,
`RawServiceTypeCall` must already exist before your file's `class` line
runs — hence the explicit `require_relative`. Forgetting it works by
accident whenever your filename happens to alphabetically sort after
`raw_service_type_call.rb`, and breaks the moment it doesn't. Don't rely
on the accident.

### How to find `SERVICE_TYPE_URI` for a new service type

Two options:

- `cache/servicetypes.json` (rebuilt via `GET /refresh-servicetypes`) lists
  every known `[type_uri, label]` pair currently discoverable in the FDP
  Index.
- Query it directly with the `sparql_query` MCP tool (or any SPARQL
  client) — service types are the `?type` bound by:
  ```sparql
  PREFIX dcat: <http://www.w3.org/ns/dcat#>
  PREFIX dcterms: <http://purl.org/dc/terms/>
  SELECT DISTINCT ?type WHERE {
    ?s a dcat:DataService ; dcterms:type ?type .
  }
  ```

## When *not* to use `RawServiceTypeCall`

Only fits a service type that takes no input — a fixed lookup, like
`IUCN_categorization`'s "no parameters, returns whatever this provider
currently has." A service type whose interface takes real parameters
(e.g. `species_location`'s species-name lookup) needs its own `call` that
accepts and forwards those arguments — write it as a standalone tool
(shape 1 above) instead of forcing it through this base class.

## Testing

See `spec/mcp_routes_spec.rb` for the pattern: `stub_vp` (from
`spec/spec_helper.rb`) installs an `instance_double(VP)`, so a new
`RawServiceTypeCall` subclass's test only needs to stub `retrieve_sevices`
and `guess_best_content_type` plus `Service.execute_get`, never touching
the network. `instance_double` verifies stubbed methods against the real
class's signature, so a renamed/removed method fails the spec immediately
rather than silently passing.
