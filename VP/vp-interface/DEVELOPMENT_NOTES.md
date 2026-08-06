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

- Exposing more of the VP's functionality as additional MCP tools (only
  `keyword_search` exists today).
- A raw/ad-hoc SPARQL-query MCP tool, where the LLM is given the DCAT/`ejp:`
  data model and writes its own queries — plausible (similar to
  text-to-SQL) but needs query validation/dry-run before returning results,
  and should stay read-only.
- DataService health/liveness monitoring, and eventually one MCP tool per
  registered data service so an AI UI could execute any of them directly.
