# Development notes — `fdp-index-sparql` branch

Session handoff doc, kept in git so it follows you across machines. Local
`main` reflects what's actually deployed to production
(`vp.linkeddata.systems`) — this branch is where the in-progress cleanup
lives, not yet deployed anywhere.

## Where things stand

Four commits ahead of `main`:

1. **MCP endpoint + cleanup (on `main` already)** — `app/controllers/mcp_routes.rb`
   implements a hand-rolled MCP JSON-RPC server (no SDK, deliberately — see
   below) exposing a `keyword_search` tool, live at
   `https://vp.linkeddata.systems/flair-gg-vp-server/mcp`, registered as a
   Claude.ai connector and in Claude Code. Also on `main`: fixed
   `Discoverable#to_json` (was silently falling back to Ruby's
   object-inspect string), removed the dead `VP/Docker` lighttpd/CGI stack
   (confirmed unreachable/unused).
2. **`75947e4` — FDP Index SPARQL migration.** The VP no longer talks to
   GraphDB directly. All SPARQL queries now go through the FDP Index's
   `GET/POST /search/sparql` proxy (bearer-token auth), via a new
   `lib/fdp_index_client.rb` (deliberately decoupled from `VP`/`Discoverable`
   — this is the piece worth spinning into a standalone gem later if anyone
   else needs an FDP Index client). New required env var:
   `FDPINDEX_API_TOKEN`. `docker-compose.yml` no longer needs
   `network_mode: host` (that was only for reaching a host-bound GraphDB
   port).
3. **`05682a8` — routes.rb cleanup.** Moved business logic out of
   `app/controllers/routes.rb` into `lib/vp.rb` (service-type cache refresh,
   ontology CURIE normalization, service-label/notebook-URL builders) and
   `lib/wordcloud.rb` (it now fully owns its own `WCREFRESHING` lock file
   instead of routes.rb separately poking the same file). Added one
   `respond_with` Sinatra helper collapsing 7x duplicated html/json
   content-negotiation dispatch. Fixed a real bug found while testing:
   `ServiceCollection#vpgraph=` no longer exists (renamed to `#endpoint` in
   an earlier commit, `b0dd1a0`) but routes.rb still called it — 500 on
   `GET /retrieve-services`.
4. **`6c04d4d` + `3443903` — RSpec foundation and expanded coverage.** 66
   examples, fully hermetic (WebMock blocks all real network,
   `instance_double(VP)` decouples route specs from live data), runs in
   ~70ms. Covers every route in `routes.rb`, `VP`'s core business methods,
   `Discoverable`, `Wordcloud`, and the cache helpers. See
   `spec/retrieve_services_spec.rb` for the regression test on bug #3 above
   — it deliberately uses a *real* `ServiceCollection` (only its two
   network-touching methods stubbed) rather than a plain double, so a
   reintroduced call to a renamed/removed method fails loudly.

## Running it locally

```
cd VP/vp-interface
docker compose up -d          # needs .env with FDPINDEX_API_TOKEN (see below)
bundle exec rspec             # or `rake` (spec + rubocop)
```

**`FDPINDEX_API_TOKEN` is not in git.** It's a bearer token for
`https://index.linkeddata.systems` (an FDP Index `/api-keys`-issued token,
months-long lifetime). Set it in `VP/vp-interface/.env` (gitignored) as
`FDPINDEX_API_TOKEN=<token>`, or ask for a fresh one if it's expired/lost.
`docker-compose.yml` passes it through via `${FDPINDEX_API_TOKEN}`.

The Sinatra app also expects `FDPINDEX` (the FDP Index base URL, currently
`https://index.bgv.cbgp.upm.es/` — separate from the `index.linkeddata.systems`
host that serves `/search/sparql`, these are genuinely different things) and
`FDPSPARQL` (now `https://index.linkeddata.systems/search/sparql`).

## Deliberate design choices worth knowing before touching this code

- **MCP is hand-implemented, not via an SDK** (plain JSON-RPC over Sinatra).
  Deliberate: keeps everything in the project's native Ruby/Sinatra stack
  rather than pulling in Node/Python tooling the maintainer doesn't use day
  to day.
- **`main` is a real, in-use deployment**, not a demo — a colleague
  (Alberto) relies on it for thesis work. Don't deploy branch work to
  production without an explicit go-ahead; test on a branch first (as this
  branch already does).
- **Scale matters more than it looks right now.** Only 6 germplasm banks
  are registered today; expected to grow to 52 at national rollout, and
  there's a longer-term ambition to also run a separate deployment for
  ERDERA's FDP Index, which already has hundreds of entries. Each VP
  instance still only talks to *one* FDP Index (no multi-tenancy needed —
  separate deployments handle that) but should stay efficient as entry
  counts grow. This is why e.g. request specs stub `VP.current_vp` rather
  than depending on live data size, and why the `Wordcloud#count_words`
  O(n²) bug got fixed opportunistically even though word cloud itself is
  low priority.

This branch has since been merged into `main` (2026-08-06) - the sections
above describe how it got there. Kept as history, not a live TODO list.

## Known, deliberately deferred issues (not urgent, don't fix without asking)

- ~~Stale `IUCN_categories` shallot query on the five migrated germplasm-bank
  hosts~~ **Fixed 2026-08-06/07**: `jbo`, `jbclm`, `bgusal`, `jbs`, `urjc`
  (all `*.linkeddata.systems`) were serving an old query pattern
  (`fao:endangerment_category`/`sio:SIO_000300`, matching plain-English
  category strings through an assessment-chain) instead of the current one
  in `Data Service Configs/Shallot/shared-queries/IUCN_categories.rq`
  (`dwc:scientificName` + `iucn:threatStatus` against GBIF vocabulary
  URIs) - confirmed not a data-migration gap (the RDF4J repositories had
  the current-shape triples all along; only the shallot deployment was
  stale), fixed by manually pasting the current query onto each host and
  restarting shallot. `urjc` needed a second pass - the paste there had
  picked up one stray leading `k` character before the first `#+`
  directive comment, breaking shallot's comment-stripping for just that
  line and passing `k#+ summary: ...` through as literal (invalid) SPARQL
  to Virtuoso ("Lexical error... after prefix 'k'"). All six providers
  (including `fdp.bgv.cbgp.upm.es`) now confirmed returning real
  `iucn_endangerment_status` data end-to-end.

- ~~Word cloud is slow on refresh~~ **Fixed 2026-08-06**: the underlying
  SPARQL queries already `SELECT DISTINCT`, so within one run each
  annotation URI was only ever resolved once - the actual slowness was a
  full refresh re-resolving every one of those (thousands of, and growing
  toward hundreds-of-providers-scale) distinct URIs from scratch every
  time via a live external HTTP call (`ontology_annotations(uri:)` in
  `lib/metadata_functions.rb`), even though an ontology term's label is
  effectively permanent. Fixed with a process-wide cache backed by
  `./cache/ontology_annotations.json` (`OntologyAnnotationCache`, same
  thaw/freeze pattern as the keyword/service-type caches in
  `lib/cache.rb`) - a cold cache behaves exactly as before, but every
  subsequent refresh only pays the network cost for genuinely new URIs.
  A previously-considered alternative (swap to the FDP Index's own
  `/label` endpoint for cached lookups) is now superseded - it would only
  have addressed per-call latency, not the repeated-work-across-refreshes
  shape that was the real problem.

## Ideas logged for (much) later, not started

- ~~Exposing more of the VP's functionality as additional MCP tools~~ and
  ~~a raw/ad-hoc SPARQL-query MCP tool~~ - **both done**: `sparql_query`
  and `iucn_endangerment_status` now exist alongside `keyword_search`
  (see `lib/mcp_tools/`). `iucn_endangerment_status` is also the first
  instance of "one MCP tool per registered data service type" from the
  idea below, via the `RawServiceTypeCall` base class.
- DataService health/liveness monitoring, and eventually one MCP tool per
  registered data service so an AI UI could execute any of them directly
  (partially started - see above).
- **Word-cloud exclude/stopword list** (2026-08-06): now that the 0.3.6
  cache fix lets a full refresh actually complete, generic ontology-level
  terms like "Protein" or "Location" are dominating the cloud over more
  genuinely informative tags - a domain-specific stopword list (excluded
  in `VP#verbose_annotations`/`Wordcloud`, before frequencies are
  counted) would fix this. Not started; needs an actual candidate word
  list from real output first.
- **Better OpenAPI interface-definition support** (2026-08-06, from a
  conversation about `ServiceCollection#collect_similar_services`'s
  DCAT-endpoint-vs-OpenAPI-path matching, since 0.3.8 switched a mismatch
  from excluding the provider to just flagging it as unverified - not
  urgent, don't start without asking):
  - No path-template-variable support anywhere in the execution path
    (`execute_data_services`/`execute_data_services_api` only handle
    query-string GET params or a POST body). A service whose real
    endpoint has a variable *in the path* (e.g. the TOGO endpoint behind
    `species_by_ena_id.yaml` - see that file's comment) can't actually be
    executed correctly through the generic mechanism today, matched or
    not; someone currently has to hand-pick a single concrete endpoint
    value into the DCAT record to work around it. Properly fixing this
    means parsing `{param}` placeholders out of the OpenAPI path,
    offering them as form inputs alongside the query/body params, and
    substituting them into the endpoint URL before executing - real work,
    not a one-liner.
  - No Ruby gem does this dynamic "discover an arbitrary OpenAPI doc at
    runtime, build a working parameterized client from it" job - looked
    into it (2026-08-06): `openapi3_parser` (already used here) covers
    parsing/validation, but the closest things do the opposite direction
    (validate/generate docs for *your own* API - `committee`, `rswag`,
    `rspec-openapi`, also already used) or are static code-generators for
    *one known* spec (`openapi-generator`), not useful across dozens of
    independently-run, never-seen-before partner specs. This is likely
    staying bespoke regardless of how much of it gets rebuilt.
  - Separately: the Swagger-2.0-to-OpenAPI-3.0 conversion step
    (`docker-compose.yml`'s `swagger-converter` service, `swaggerapi/swagger-converter`)
    is a whole extra Node-based Docker container specifically because
    Ruby doesn't have a mature native equivalent of `swagger2openapi`.
    Worth a look someday to see if that's changed, but not expected to
    have.
