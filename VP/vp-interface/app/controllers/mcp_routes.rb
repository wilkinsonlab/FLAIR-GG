# frozen_string_literal: false

require 'sinatra/base'
require 'json'

# Reopens {VPRoutes} (defined in +routes.rb+) to add the MCP (Model Context
# Protocol) endpoint, kept in its own file so +routes.rb+ doesn't have to grow
# further. Both files declare the same class, so Ruby merges their route
# definitions into one Sinatra app; {ApplicationController} still inherits
# from the single, combined +VPRoutes+ class.
#
# Implements the MCP "Streamable HTTP" transport as plain JSON-RPC 2.0 over
# a single POST endpoint — no MCP SDK required. Exposes one tool,
# +keyword_search+, backed by {VP#keyword_search_shell}.
class VPRoutes < Sinatra::Base
  MCP_PROTOCOL_VERSION = '2025-06-18'.freeze

  SPARQL_TOOL_DESCRIPTION = <<~DESCRIPTION.freeze
    [EXPERIMENTAL] Executes a read-only SPARQL 1.1 SELECT query directly
    against the FDP Index, the same live network of FAIR Data Points that
    keyword_search searches. Use this for anything keyword_search can't
    answer - counting, grouping, filtering on dates or specific properties,
    or combining several conditions in one query. SELECT only: no ASK,
    CONSTRUCT, DESCRIBE, or updates. Results come back as JSON rows, one
    object per SPARQL result row, string-valued. A LIMIT is added
    automatically (default 100) if you don't include one.

    Key namespaces:
      PREFIX fdp: <https://w3id.org/fdp/fdp-o#>
      PREFIX ejp: <https://w3id.org/ejp-rd/vocabulary#>
      PREFIX dcat: <http://www.w3.org/ns/dcat#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

    A resource is publicly discoverable only if it has:
      ?resource ejp:vpConnection ejp:VPDiscoverable .

    Example 1 - list discoverable FAIR Data Points with their titles:
      PREFIX fdp: <https://w3id.org/fdp/fdp-o#>
      PREFIX ejp: <https://w3id.org/ejp-rd/vocabulary#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      SELECT ?resource ?title WHERE {
        ?resource a fdp:FAIRDataPoint ;
          dcterms:title ?title ;
          ejp:vpConnection ejp:VPDiscoverable .
      }

    Example 2 - keyword search over title/description/keyword fields:
      PREFIX dc: <http://purl.org/dc/terms/>
      PREFIX dcat: <http://www.w3.org/ns/dcat#>
      SELECT DISTINCT ?resource ?kw WHERE {
        VALUES ?searchfields { dc:title dc:description dc:keyword dcat:keyword }
        ?resource ?searchfields ?kw .
        FILTER(CONTAINS(LCASE(str(?kw)), LCASE("wheat")))
      }

    Example 3 - count data services of a given ontology type:
      PREFIX dcat: <http://www.w3.org/ns/dcat#>
      PREFIX dcterms: <http://purl.org/dc/terms/>
      SELECT (COUNT(?s) AS ?count) WHERE {
        ?s a dcat:DataService ;
          dcterms:type <http://edamontology.org/operation_3436> .
      }
  DESCRIPTION

  MCP_TOOLS = [
    {
      name: 'keyword_search',
      description: 'Searches the FLAIR-GG VP network for resources whose metadata ' \
                    'contains the given keyword. Case-insensitive.',
      inputSchema: {
        type: 'object',
        properties: {
          keyword: {
            type: 'string',
            description: 'The term to search for'
          }
        },
        required: ['keyword']
      }
    }.freeze,
    {
      name: 'sparql_query',
      description: SPARQL_TOOL_DESCRIPTION,
      inputSchema: {
        type: 'object',
        properties: {
          query: {
            type: 'string',
            description: 'A read-only SPARQL 1.1 SELECT query (see tool description for namespaces and examples)'
          }
        },
        required: ['query']
      }
    }.freeze
  ].freeze

  # @!group MCP

  # @!method post_mcp(body)
  # Single JSON-RPC 2.0 endpoint implementing the MCP Streamable HTTP transport.
  #
  # Handles the +initialize+, +notifications/initialized+, +tools/list+ and
  # +tools/call+ methods. +tools/call+ currently supports only +keyword_search+,
  # which delegates to {VP#keyword_search_shell} exactly as {#post_keyword_search} does.
  #
  # @param [Hash] body JSON-RPC request, e.g.
  #   <tt>{ "jsonrpc": "2.0", "id": 1, "method": "tools/list" }</tt>
  # @return [String, JSON] JSON-RPC response
  post %r{/flair-gg-vp-server/mcp/?} do
    content_type :json
    request_body = JSON.parse(request.body.read.to_s)
    id = request_body['id']
    method_name = request_body['method']
    request_params = request_body['params'] || {}

    case method_name
    when 'initialize'
      halt mcp_result(id, {
                         protocolVersion: MCP_PROTOCOL_VERSION,
                         capabilities: { tools: {} },
                         serverInfo: { name: 'flair-gg-vp-server', version: '1.0.0' }
                       }.to_json)
    when 'notifications/initialized'
      halt 202, ''
    when 'tools/list'
      halt mcp_result(id, { tools: MCP_TOOLS }.to_json)
    when 'tools/call'
      halt mcp_call_tool(id: id, params: request_params)
    else
      halt mcp_error(id, -32_601, "Method not found: #{method_name}")
    end
  end

  # @!endgroup

  private

  # Dispatches a +tools/call+ request to the named tool and wraps the result
  # as MCP tool-call content.
  #
  # @param id [Integer, String, nil] JSON-RPC request id
  # @param params [Hash] must contain +name+ and, for +keyword_search+, an
  #   +arguments+ hash with a +keyword+ string
  # @return [String] JSON-RPC response
  def mcp_call_tool(id:, params:)
    arguments = params['arguments'] || {}
    case params['name']
    when 'keyword_search'
      keyword = arguments['keyword'] ? arguments['keyword'].strip : ''
      discoverables = VP.current_vp.keyword_search_shell(keyword: keyword)
      mcp_result(id, { content: [{ type: 'text', text: discoverables.to_json }] }.to_json)
    when 'sparql_query'
      begin
        rows = VP.execute_raw_sparql(query: arguments['query'])
        mcp_result(id, { content: [{ type: 'text', text: rows.to_json }] }.to_json)
      rescue ArgumentError, SPARQL::Client::ClientError, SPARQL::Client::ServerError => e
        mcp_error(id, -32_000, "Query failed: #{e.message}")
      end
    else
      mcp_error(id, -32_602, "Unknown tool: #{params['name']}")
    end
  end

  # Builds a successful JSON-RPC 2.0 response.
  #
  # @param id [Integer, String, nil] the request id being answered
  # @param result_json [String] the already-serialized JSON value of +result+
  # @return [String] JSON-RPC response
  def mcp_result(id, result_json)
    %({"jsonrpc":"2.0","id":#{id.to_json},"result":#{result_json}})
  end

  # Builds a JSON-RPC 2.0 error response.
  #
  # @param id [Integer, String, nil] the request id being answered
  # @param code [Integer] JSON-RPC error code
  # @param message [String] human-readable error message
  # @return [String] JSON-RPC response
  def mcp_error(id, code, message)
    %({"jsonrpc":"2.0","id":#{id.to_json},"error":{"code":#{code},"message":#{message.to_json}}})
  end
end
