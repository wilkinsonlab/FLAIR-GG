# flair-box-daemon (LEGACY)

> **Legacy component.** This is the transformation daemon of the original GraphDB-based FLAIR-in-a-Box
> (image `markw/flair-box-daemon`). The existing GraphDB installations still run it, so the source stays here
> for rebuilding and patching that image. **New installations use Sextans Fix with the FLAIR-GG data model
> instead** (see [FLAIR-in-a-Box](../FLAIR-in-a-box/)). Do not start new work here.
>
> It will be retired once the Google Sheets CSV fetch (below) has been ported to the Sextans Fix daemon. See
> [TODO.md](../TODO.md).

## What it does

On `GET /` it:

1. `git pull`s this repository (cloned into the image at build time) and copies
   `SemanticModel/YARRRML/*.pre-yaml` into `/data`. **The live mappings therefore come from `main` on GitHub.**
2. Downloads each CSV from Google Sheets, if configured:
   `ADMIN_SHEET`, `GERMPLASM_SHEET` and `LOCATION_SHEET` hold a sheet's sharing URL. An empty value means "don't
   use Sheets for this type" and deletes any old `/data/<type>.csv`.
3. Replaces `|||baseURI|||` in the mappings with the `baseURI` environment variable (default
   `http://example.org/`).
4. Calls the `yarrrml-rdfizer` container (see [`yarrrml-rml-mapper-flair`](../yarrrml-rml-mapper-flair/)) once
   per CSV, then PUTs the resulting Turtle into the GraphDB `germplasm` repository.

It is not meant to be run on its own. It assumes the GraphDB FLAIR-in-a-Box environment around it.
