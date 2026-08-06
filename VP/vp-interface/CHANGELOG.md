# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file starts now (2026-08-06); earlier history (the MCP endpoint's
`keyword_search` and `sparql_query` tools, the FDP Index SPARQL migration,
the RSpec foundation, etc.) predates it and isn't backfilled — see git log
and `DEVELOPMENT_NOTES.md` for that history.

## [1.2.0] - 2026-08-06

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

- Merged the `fdp-index-sparql` branch into `main` now that the
  linkeddata.systems/CESVIMA server migration is complete: the RSpec
  foundation (89 examples), the routes.rb/lib business-logic extraction,
  the generated OpenAPI doc, the SPARQL-injection fix, and the full MCP
  tool refactor from 1.1.0 below. Two DESCRIPTION improvements that had
  been made independently on `main` (sparql_query's contact/curator-lookup
  example and web-search-fallback guidance; keyword_search's pointer to
  sparql_query for anything beyond a simple keyword match) were ported
  forward into the merged per-file tool structure rather than lost.

## [1.1.0] - 2026-08-06

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

### Changed

- `mcp_call_tool`'s error handling generalized from a per-tool exception
  whitelist to one `rescue StandardError` at the dispatch level, now that
  tool implementations are decoupled from the router — a new tool doesn't
  need the router to know which exception classes it might raise.
