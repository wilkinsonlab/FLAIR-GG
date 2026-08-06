# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file starts now (2026-08-06); earlier history (the MCP endpoint's
`keyword_search` and `sparql_query` tools, the FDP Index SPARQL migration,
the RSpec foundation, etc.) predates it and isn't backfilled — see git log
and `DEVELOPMENT_NOTES.md` for that history.

**Versioning bootstrap (2026-08-06):** this file briefly used an
independent `1.x` numbering (see git history of this file) before the
Docker image's own pre-existing `0.3.x` tag scheme was pointed out —
neither `1.1.0` nor `1.2.0` was ever actually built/tagged. Squashed
together below as `0.3.6`, incrementing from the last real image tag
(`0.3.5`), with `VERSION`, the gemspec, and `docker-compose.yml`'s image
tag now all aligned to this one number going forward.

## [0.3.8] - 2026-08-06

### Changed

- `ServiceCollection#collect_similar_services`: a provider whose
  DCAT-registered endpoint doesn't match any path in its OpenAPI document
  is no longer excluded from `retrieve-services` results - it's still
  listed (checkbox and all), with `Service#successful` false and a
  per-provider warning shown inline (`services_layout.erb`) plus in the
  aggregate warnings list, worded to say what's actually at risk
  ("parameters could not be verified... may fail if it requires
  parameters not shared by other matched providers"). Execution was
  never affected by this match either way - `Service#execute_get`/`_post`
  always hit the raw DCAT-registered endpoint directly, never anything
  derived from the OpenAPI match - so excluding was strictly worse than
  warning: a provider whose real endpoint genuinely can't be expressed as
  a single non-templated OpenAPI path (e.g. one needing a path variable,
  see `species_by_ena_id.yaml`) was indistinguishable from an actually
  broken one, and either had to be hidden or have a fake endpoint value
  spoofed into its DCAT record just to make it reappear. The minimized
  JSON collection (`ServiceCollection#minimize_service_collection`) also
  gained a `verified` field per service, so API/MCP consumers see the
  same signal, not just the HTML form.

## [0.3.7] - 2026-08-06

### Fixed

- `wordcloud.erb` wasn't rendering, or rendered inconsistently across
  browsers/environments, for two real reasons found once the 0.3.6 cache
  fix let a full label-resolution run actually complete for the first
  time:
  - Three competing jQuery loads, two over plain `http://` on an HTTPS
    page (mixed-content-blocked by most browsers) - including one that
    reloaded a *different* jQuery version at the bottom of the page,
    after the jQCloud plugin had already attached itself to the first
    one. Collapsed to a single HTTPS jQuery load; also dropped a dead
    IE6/`chrome-frame` compatibility block.
  - Word labels (pulled from external, uncontrolled ontology services)
    were interpolated into the inline `<script>` block as raw,
    unescaped JS string literals - a label containing so much as a `"`
    broke the JS syntax and silently killed the entire script, cloud
    included. Now built via `.to_json` (plus escaping `/` so a label
    containing `</script>` can't prematurely close the tag either).
    Previously this rarely triggered since a full resolution run had
    never actually completed; now that it reliably does, real external
    labels hit it far more often. New spec asserts a label containing
    quotes, a backslash, and a `</script>` sequence round-trips as valid
    JSON rather than breaking the page.

## [0.3.6] - 2026-08-06

### Added

- `GET /flair-gg-vp-server/mcp` — human-readable rendering of the MCP tool
  catalogue (same data as `tools/list`, no JSON-RPC envelope), so the tools
  available at this endpoint can be read in a browser, or shared as a
  plain link, without an MCP client or a read of the source code.
- `lib/mcp_tools/` — MCP tool metadata (name, description, input schema)
  and implementation now live one file per tool in this folder, rather
  than being embedded in `app/controllers/mcp_routes.rb`. The router only
  knows how to list `MCP_TOOL_CLASSES` and dispatch a call to whichever
  tool was named.
- `iucn_endangerment_status` MCP tool — executes a raw `GET` against every
  live `IUCN_categorization` data service currently discoverable in the
  FLAIR-GG VP network. Providers are found via the VP's own
  service-discovery search (`VP#retrieve_sevices`), not a hand-written
  SPARQL query, so newly added or relocated providers are picked up
  automatically. Deliberately skips the LDP-upload/notebook wiring the
  human UI and ComfyUI workflow integration use — an MCP caller gets the
  raw provider responses back directly. One provider failing (e.g. a
  mid-migration host) surfaces as `{"error": "..."}` for that provider's
  key; it doesn't sink the whole call.
- `lib/mcp_tools/raw_service_type_call.rb` — reusable base class behind
  `iucn_endangerment_status`, for any future "one MCP tool per DCAT
  service type" tool whose interface takes no parameters (a fixed lookup,
  per the FLAIR-GG convention that every provider under the same `dc:type`
  implements the same interface). Also builds each tool's `DESCRIPTION`
  from a `summary:` plus an optional `reference_notebook_filename:`,
  appending a pointer to that FLAIR-GG-Analytics notebook's **raw**
  (fetchable-as-JSON) GitHub URL — not `VP#notebook_url`'s JupyterLite
  viewer link, which is an HTML app an LLM can't read as content — so a
  tool-calling LLM has a documented reference implementation to consult
  for how this kind of data is normally analyzed (categorized, plotted,
  etc.), without the tool itself returning any notebook content.
- `lib/mcp_tools/README.md` — contributor guide for adding a new MCP tool,
  covering both shapes (plain standalone tool vs. `RawServiceTypeCall`
  subclass), how to find a service type's `SERVICE_TYPE_URI`, and a
  load-order gotcha specific to this folder's `require_rel` usage. Linked
  from the main `README.md`.

### Fixed

- Word-cloud/service-type-label refresh was slow at scale: `ontology_annotations(uri:)`
  re-resolved every distinct annotation URI via a live external HTTP call
  (EBI, Ontobee, NCBO, ...) on every single refresh, even though the
  underlying SPARQL queries already `SELECT DISTINCT` and an ontology
  term's label is effectively permanent. Added a process-wide cache
  (`OntologyAnnotationCache`, backed by `./cache/ontology_annotations.json`,
  same thaw/freeze pattern as the existing keyword/service-type caches) so
  only genuinely new URIs pay the network cost - a cold cache behaves
  exactly as before, every subsequent refresh is fast.

### Changed

- `mcp_call_tool`'s error handling generalized from a per-tool exception
  whitelist to one `rescue StandardError` at the dispatch level, now that
  tool implementations are decoupled from the router — a new tool doesn't
  need the router to know which exception classes it might raise.
- Merged the `fdp-index-sparql` branch into `main` now that the
  linkeddata.systems/CESVIMA server migration is complete: the RSpec
  foundation (89 examples), the routes.rb/lib business-logic extraction,
  the generated OpenAPI doc, the SPARQL-injection fix, and the full MCP
  tool refactor above. Two DESCRIPTION improvements that had been made
  independently on `main` (sparql_query's contact/curator-lookup example
  and web-search-fallback guidance; keyword_search's pointer to
  sparql_query for anything beyond a simple keyword match) were ported
  forward into the merged per-file tool structure rather than lost.

- `GET /flair-gg-vp-server/mcp` — human-readable rendering of the MCP tool
  catalogue (same data as `tools/list`, no JSON-RPC envelope), so the tools
  available at this endpoint can be read in a browser, or shared as a
  plain link, without an MCP client or a read of the source code.
- `lib/mcp_tools/` — MCP tool metadata (name, description, input schema)
  and implementation now live one file per tool in this folder, rather
  than being embedded in `app/controllers/mcp_routes.rb`. The router only
  knows how to list `MCP_TOOL_CLASSES` and dispatch a call to whichever
  tool was named.
- `iucn_endangerment_status` MCP tool — executes a raw `GET` against every
  live `IUCN_categorization` data service currently discoverable in the
  FLAIR-GG VP network. Providers are found via the VP's own
  service-discovery search (`VP#retrieve_sevices`), not a hand-written
  SPARQL query, so newly added or relocated providers are picked up
  automatically. Deliberately skips the LDP-upload/notebook wiring the
  human UI and ComfyUI workflow integration use — an MCP caller gets the
  raw provider responses back directly. One provider failing (e.g. a
  mid-migration host) surfaces as `{"error": "..."}` for that provider's
  key; it doesn't sink the whole call.
- `lib/mcp_tools/raw_service_type_call.rb` — reusable base class behind
  `iucn_endangerment_status`, for any future "one MCP tool per DCAT
  service type" tool whose interface takes no parameters (a fixed lookup,
  per the FLAIR-GG convention that every provider under the same `dc:type`
  implements the same interface). Also builds each tool's `DESCRIPTION`
  from a `summary:` plus an optional `reference_notebook_filename:`,
  appending a pointer to that FLAIR-GG-Analytics notebook's **raw**
  (fetchable-as-JSON) GitHub URL — not `VP#notebook_url`'s JupyterLite
  viewer link, which is an HTML app an LLM can't read as content — so a
  tool-calling LLM has a documented reference implementation to consult
  for how this kind of data is normally analyzed (categorized, plotted,
  etc.), without the tool itself returning any notebook content.
- `lib/mcp_tools/README.md` — contributor guide for adding a new MCP tool,
  covering both shapes (plain standalone tool vs. `RawServiceTypeCall`
  subclass), how to find a service type's `SERVICE_TYPE_URI`, and a
  load-order gotcha specific to this folder's `require_rel` usage. Linked
  from the main `README.md`.

### Changed

- `mcp_call_tool`'s error handling generalized from a per-tool exception
  whitelist to one `rescue StandardError` at the dispatch level, now that
  tool implementations are decoupled from the router — a new tool doesn't
  need the router to know which exception classes it might raise.
