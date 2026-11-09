# TODO

Backlog for FLAIR-GG's move onto the [Sextans Suite](https://github.com/wilkinsonlab/Sextans-Suite) and the
things noticed along the way, so they don't get lost. Newest decisions first within each section.

## Sextans Suite (other repository)

- **Merge and release the Sextans data-model selection.** Sextans-Suite branch `data-model-selection` (commit
  `553ea13`, pushed, not merged) adds the install-time choice between the CARE-SM-2 and FLAIR-GG models and the
  model-driven daemon. Sextans `main` has since gained the November 2026 security work (rack DoS fix, CA strip,
  digest pinning, multi-stage `cdeb2`) in the same files, so the merge needs conflict resolution. Then rebuild
  and push the images with `Sextans/Security/security-patch.sh`. **Until then, the released `cdeb2` image has no
  FLAIR-GG model, so a new FLAIR-GG node cannot actually be installed as the FLAIR-in-a-Box docs describe.**
  Deferred 2026-11-09 (Mark: "leave Sextans alone" for this session).
- **Port the Google Sheets CSV fetch to the Sextans Fix daemon, then retire the legacy fork.** The only
  implementation is `FLAIR-box-daemon/transform.rb#update_csv` (per-type `*_SHEET` URLs; empty means off).
  Mark wants Sheets kept for now. Make it opt-in and model-independent (any data type, not just FLAIR's three),
  and treat it as new outbound network access from the Fix stack (flag it for the planned Sextans pentest).
  Once it ships, delete [`FLAIR-box-daemon/`](FLAIR-box-daemon/) and
  [`yarrrml-rml-mapper-flair/`](yarrrml-rml-mapper-flair/), which are kept only because the six legacy GraphDB
  banks run them and Sheets lives there.
- **FLAIR-GG sanity checker ("toolkit").** The hook exists (`toolkit:` in Sextans' `Daemon/models/flair-gg.yml`,
  currently empty, so the daemon logs "defines no toolkit" and moves on). Until it exists, the only safety net is
  the daemon's RDF-validity abort. Suggested checks: expected columns present (derivable from the `$(col)`
  references in each mapping), ISO 8601 dates, numeric fields numeric, `uniqid` unique, no empty required
  values. Shape: a small service like CARE-SM's `caresm` (POST -> check/prepare `/data`), started via its own
  compose profile.
- **Automate FLAIR-GG's FDP configuration, as ERDERA's already is.** Sextans Sight installs identically for
  every project. The domain-specific FDP set-up happens *afterwards*, against the running FDP. For rare
  diseases this is a one-shot script, `Sextans/FDP_Configs/ERDERA_Base/run-erdera-configuration.sh` (uploads
  SHACL schemas, creates resource definitions, wires them to Catalog/Distribution). For FLAIR-GG it is still a
  manual click-through tutorial in [`FDP-Configuration/README.md`](FDP-Configuration/README.md) (SHACL in
  `FDP-Configuration/shacl/`, two Data Service resource definitions under Distribution and Catalog). The two
  are structurally almost the same, so a `FDP_Configs/FLAIR_Base/` (or a script here reusing ERDERA_Base's
  code) is the natural next step. Could also apply the `FDP-Configuration/branding/` files.
- **Untested edge: CSV chunking.** Sextans' mapper splits each CSV into 200-row chunks and maps each chunk
  separately. A mapping that joins across rows would break. FLAIR's mappings don't appear to; confirm with real
  data.
- **Branding question.** The Rare2FAIR team disliked "Sextans" branding. Check whether FLAIR-GG partners mind.

## Virtual Platform

- **Shallot vs Severance (known hard problem, deferred).** Shallot (a GRLC fork) assumes a *public* database.
  Sextans deliberately locks anonymous SPARQL reads, so new Sextans nodes need Severance instead, whose
  interface differs from Shallot's plain OpenAPI. Requirement: the VP reaches legacy Shallot services and new
  Severance services through the same API, without caring which kind of node it talks to. Options, none
  evaluated: a facade presenting Shallot's OpenAPI in front of Severance (a Severance "shallot-facade" was
  started in the Severance repo, branch `grlc-facade`); an OpenAPI-compatible surface on Severance; a client-side
  abstraction in the VP. Do it on its own branch.

## Legacy GraphDB banks

- **Set a real `baseURI` on each legacy bank.** Since this repository's mappings started using `|||baseURI|||`
  (merged to `main` 2026-11-09), each legacy bank's next `flair-box-daemon` run re-mints all its records under
  the `baseURI` in its `.env`. Until then they were all under `http://my_example.com/` (checked 2026-11-09:
  BGV ~680k triples, JBS ~124k, JBCLM ~58k, JBO ~40k, URJC ~32k, BGUSAL ~2k). Some current values look like
  example placeholders (`proof.of.life.for.sure`, `germplasm.for.sure`). Suggested:
  `https://<bank>.linkeddata.systems/data/`. Nothing in the VP code or the Analytics notebooks depends on
  `my_example.com`.

## This repository

- **Decide whether the Driada pipeline should use `|||baseURI|||` too.**
  `VP/wrapped_services/.../driada/transformation/driada_model.py` still mints under `http://my_example.com/`.
- **Restyle the subpages** (FAQ, VP, Proxy, SemanticModel, TransformationPipeline) to match the new homepage.
  They still use `flexbox.css`.
- **Homepage figures are hand-maintained.** "10 banks", "~20%" and "34 data services" in `index.html`, and the
  member list in both `index.html` and `metadata.jsonld`, need updating as the network grows. The JSON-LD in
  `index.html` is an embedded copy of `metadata.jsonld`; keep them in sync.
- **`cite-as` for the homepage.** FAIR Signposting `cite-as` needs a persistent identifier for the page itself.
  `w3id.org/flair-gg` points to the VP, so this would need a new w3id.
- **Swagger UI host.** The homepage links `bgv.cbgp.upm.es/swagger`. It wasn't yet available at
  `bgv.linkeddata.systems` on 2026-11-09.
