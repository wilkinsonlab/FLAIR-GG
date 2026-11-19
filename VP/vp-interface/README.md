# To Run the VP front-end

FDPINDEX=https://index.bgv.cbgp.upm.es/ ruby app/controllers/application_controller.rb

Normally it runs with `docker compose up -d` (see `docker-compose.yml`), with
its settings in a `.env` file next to it. `.env` is not in git.

## Configuration (environment variables)

| Variable | Required | Meaning |
| --- | --- | --- |
| `FDPINDEX` | yes | Base URL of the FDP Index the VP reads its network from. |
| `FDPSPARQL` | yes | The FDP Index's SPARQL proxy, e.g. `https://index.linkeddata.systems/search/sparql`. |
| `FDPINDEX_API_TOKEN` | yes | Bearer token for `FDPSPARQL` (issued by the FDP Index's `/api-keys`). |
| `LDP_HOST` | yes | **Public** base URL of the LDP server that stores service results, e.g. `https://ldp.linkeddata.systems`. The result URLs given to users, notebooks and the JSON API are built on it. |
| `LDP_USERNAME`, `LDP_PASSWORD` | yes | Account the VP uses to write results to the LDP server. Don't use the server's admin account. |
| `LDP_INTERNAL_HOST` | no | Where to upload results when the LDP server runs in the same compose stack, e.g. `http://ldp:8890`. It keeps uploads off the public internet. The URLs handed out still use `LDP_HOST`. If unset, uploads go to `LDP_HOST`. |

## Running the tests

The test gems aren't usually installed on a workstation, so run the suite
inside the VP image with the current source mounted. It needs no network:
WebMock blocks all real HTTP.

```bash
docker run --rm --network none -v "$PWD":/server/vp-interface -w /server/vp-interface \
  markw/flair-gg-vp-server:<tag> bundle exec rspec
```

## MCP tools

This server also exposes an MCP (Model Context Protocol) endpoint at
`/flair-gg-vp-server/mcp` (JSON-RPC over `POST`; human-readable tool
catalogue via plain `GET` in a browser). See
[`lib/mcp_tools/README.md`](lib/mcp_tools/README.md) for how the tool
catalogue is organized and how to add a new tool.
