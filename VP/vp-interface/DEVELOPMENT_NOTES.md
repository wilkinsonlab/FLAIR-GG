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

## Outbound HTTP: retries and the LDP upload (0.3.11)

Every service execution makes outbound HTTPS calls: one to each selected
data service, then one `PUT` of the combined results to the LDP server.
In the production set-up, both kinds of call can cross Cloudflare.
Since November 2026, a small share of those calls has failed intermittently,
in a "fails once, works on reload" pattern (see "Operational notes" below).
0.3.11 makes the VP itself tolerate this:

- **`lib/http_retry.rb` (`HttpRetry.with_retries`)** wraps
  `Service.execute_get`, `Service.execute_post` and the LDP upload. There
  are up to 3 tries in total, with 1 s and 2 s pauses. What is retried
  depends on whether the failed request could already have reached the
  service:
  - *Nothing was sent:* the connect timed out, was refused or failed DNS,
    the TLS handshake was reset, or Cloudflare returned 521/522/523.
    Retried for every method, POST included.
  - *It may have been sent:* the connection was reset mid-response, or a
    gateway returned 502/503/504/520/524. Retried only for GET and PUT.
    A POST is never sent twice.
  - *Read timeouts are never retried.* A slow service would just be slow
    again, and the repeat would push the user's request past Cloudflare's
    100 s limit.
  - The connect timeout is 15 s (RestClient's default is 60 s), so a dead
    host fails fast enough to leave room for a retry.
  - Each retry is logged as an `HttpRetry:` line in the container log.

  `execute_get` still raises once its retries are used up, as before.
  Callers decide how to report a failed provider (the MCP tools turn it
  into a per-provider `{"error": ...}`). Making the HTML page show a
  per-provider error instead of an application-error page is a separate,
  not-yet-done change.
- **`LDP_INTERNAL_HOST`.** When the LDP server is the `ldp` service in
  this same compose stack, set `LDP_INTERNAL_HOST=http://ldp:8890` (in
  `.env`). The VP then uploads results directly over the compose network
  instead of out through Cloudflare and back into the same machine:
  - The upload sends the public `Host` header (taken from `LDP_HOST`), so
    Virtuoso handles it exactly like a request arriving through the proxy.
  - Virtuoso's `Location` answer is rewritten onto `LDP_HOST`, so users,
    notebooks and the JSON API still get public URLs.
  - Before relying on it, check that the VP container can resolve the
    service: `docker exec <vp-container> getent hosts ldp`.
- A failed upload now logs why. An upload that succeeds without a
  `Location` header now returns the uploaded URL, instead of showing
  "CACHING SERVER IS DOWN".

## Operational notes: the LDP server behind the reverse proxy

The production LDP server is the `ldp` service (Virtuoso) in this compose
stack. A lighttpd reverse proxy on the host publishes it, and Cloudflare
sits in front of that. Lessons from November 2026:

- **CORS is lighttpd's job, and lighttpd needs `mod_setenv` for it.** The
  analysis notebooks run in the browser (JupyterLite on
  `wilkinsonlab.github.io`) and fetch results from the LDP server cross-site.
  Without an `Access-Control-Allow-Origin` header the browser discards the
  response, and Pyodide's `requests` reports `<Response [0]>`. A plain
  browser tab or `curl` still loads the URL fine, which makes this
  confusing. The proxy's `setenv.add-response-header` lines do nothing
  unless `mod_setenv` is loaded. lighttpd only warns about it
  (`lighttpd -tt` prints "unknown config-key: setenv.add-response-header
  (ignored)"). Load it in the proxy's site config:
  `server.modules += ( "mod_setenv", "mod_proxy" )`. To check:
  `curl -sI -H 'Origin: https://wilkinsonlab.github.io' <result URL> | grep -i access-control`.
- **Keep Virtuoso's ports bound to localhost.** Publish them in compose as
  `127.0.0.1:<port>:1111` and `127.0.0.1:<port>:8890`. lighttpd reaches the
  HTTP port locally. Admin access is through an SSH tunnel to the HTTP port,
  using a local port that's free on your own machine: another local
  Virtuoso may already hold the usual one, and the browser then silently
  reaches the wrong server. Don't use the admin account for the VP's uploads.
- **The Conductor login doesn't work through the public proxy URL.** The
  correct password gets "Invalid credentials". Reaching Virtuoso directly
  (the SSH tunnel) works. Not investigated further; use the tunnel. The
  login form posts `md5(nonce + password)` computed by `js/md5.js`. If that
  script fails to load, the browser posts the plain password instead and
  Virtuoso rejects it.
- **Intermittent failures through Cloudflare (Nov 2026; still open on
  2026-11-20).** This is what prompted the 0.3.11 retry changes above.
  - **Symptoms.** 15-33% of requests to the project's `*.linkeddata.systems`
    hosts, measured from outside, got a Cloudflare 522 after about 19.5 s.
    Users experienced it as "the first attempt fails, the reload works", in
    the VP, the Conductor and the notebooks alike. In the other direction,
    some of the server's own outgoing HTTPS connections to Cloudflare-fronted
    sites were reset right after the first TLS message. The VP saw these as
    `Errno::ECONNRESET ... SSL_connect`.
  - **Ruled out:**
    - the server's load and kernel connection tracking
    - Cloudflare Tunnel (not used; Cloudflare connects to the origin
      directly, SSL mode "Full")
    - an IPv6 origin record (there is none)
    - Cloudflare platform incidents
    - lighttpd and Virtuoso: no errors at those times.
  - **What a packet capture showed (2026-11-19, 30 min, 24 tagged requests,
    8 of them 522s).**
    - For every failed request, no connection attempt reached the server's
      network interface during the 20 s window, retries included.
    - Every attempt that did arrive was answered in under 0.1 ms.
    - The connection attempts "from Cloudflare" (five addresses in four
      Cloudflare ranges) and the replies "from Cloudflare" on the server's
      own outgoing connections all carried one shared TCP timestamp clock,
      ticking at 100 Hz. Separate Cloudflare machines can't share a clock.
    - So a TCP-terminating firewall, IPS or proxy in the hosting network
      handles the server's traffic in both directions. It sometimes drops
      new connections. The reset right after the TLS hello suggests it
      inspects the TLS server name.
  - **Likely cause:** that device's lookup or inspection failing when its
    cache is cold, which would explain "first attempt fails, the retry
    works". This is a hypothesis; only the hosting network's operators can
    confirm it. The server is a Xen VM, so the device sits outside it.
  - **The fix is outside this server:** ask the hosting network's operators
    to check their firewall/IPS policy for traffic between the server and
    Cloudflare's ranges. Until then, retries get through. The VP does this
    from 0.3.11, and the notebooks need a small retry loop around their
    `requests.get`.
  - **To re-measure,** from any machine outside the hosting network, repeat
    `curl -s -o /dev/null -w '%{http_code} %{time_total}\n'` against a
    `*.linkeddata.systems` URL a few dozen times, a few seconds apart. Any
    522 after about 19 s is this problem.

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
