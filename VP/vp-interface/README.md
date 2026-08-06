# To Run the VP front-end

FDPINDEX=https://index.bgv.cbgp.upm.es/ ruby app/controllers/application_controller.rb

## MCP tools

This server also exposes an MCP (Model Context Protocol) endpoint at
`/flair-gg-vp-server/mcp` (JSON-RPC over `POST`; human-readable tool
catalogue via plain `GET` in a browser). See
[`lib/mcp_tools/README.md`](lib/mcp_tools/README.md) for how the tool
catalogue is organized and how to add a new tool.