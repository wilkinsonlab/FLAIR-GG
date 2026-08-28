# frozen_string_literal: false

require 'sinatra/base'
require 'json'
require 'require_all'

require_rel '../../lib/mcp_tools'

# Reopens {VPRoutes} (defined in +routes.rb+) to add the MCP (Model Context
# Protocol) endpoint, kept in its own file so +routes.rb+ doesn't have to grow
# further. Both files declare the same class, so Ruby merges their route
# definitions into one Sinatra app; {ApplicationController} still inherits
# from the single, combined +VPRoutes+ class.
#
# Implements the MCP "Streamable HTTP" transport as plain JSON-RPC 2.0 over
# a single POST endpoint - no MCP SDK required. Each tool's metadata
# (name, description, input schema) and implementation live together in
# their own file under +lib/mcp_tools/+, one file per tool - see
# {McpTools::KeywordSearch} and {McpTools::SparqlQuery} - rather than being
# embedded in this routing file. This file only knows how to list the
# registered tools and dispatch a call to whichever one was named.
#
# The same path also answers plain +GET+ requests (human/browser, no
# JSON-RPC envelope needed) so the tool catalogue can be read - and shared
# as a link - without reading source code.
class VPRoutes < Sinatra::Base
  MCP_PROTOCOL_VERSION = '2025-06-18'.freeze

  # Registry of available MCP tools. Add a new tool by dropping a file in
  # +lib/mcp_tools/+ (see the existing ones for the expected shape: +NAME+,
  # +DESCRIPTION+, +INPUT_SCHEMA+ constants and a +self.call(arguments)+
  # class method) and listing its class here.
  MCP_TOOL_CLASSES = [
    McpTools::KeywordSearch,
    McpTools::SparqlQuery,
    McpTools::IucnEndangermentStatus
  ].freeze

  # +tools/list+ result entries, derived from {MCP_TOOL_CLASSES} so the
  # metadata is never hand-duplicated here.  Values are set in the tool code in ./lib/mcp_tools/*.rb,
  # so the tool's own description and input schema are always correct and up-to-date.
  MCP_TOOLS = MCP_TOOL_CLASSES.map do |tool_class|
    {
      name: tool_class::NAME,
      description: tool_class::DESCRIPTION,
      inputSchema: tool_class::INPUT_SCHEMA
    }.freeze
  end.freeze

  # @!group MCP

  # @!method get_mcp
  # Human-readable rendering of the MCP tool catalogue - the same data
  # {#post_mcp}'s +tools/list+ returns, without the JSON-RPC envelope, so
  # the tools available at this endpoint can be read in a browser (or
  # shared as a link) instead of requiring an MCP client or a read of the
  # source code.
  #
  # Content negotiation:
  # - +text/html+        → renders +:mcp_layout+
  # - +application/json+ → returns <tt>{ "tools": [...] }</tt>, matching
  #   the shape of a +tools/list+ JSON-RPC result
  #
  # @return [String, HTML] the tool catalogue
  get %r{/flair-gg-vp-server/mcp/?} do
    @tools = MCP_TOOLS
    respond_with(html_view: :mcp_layout, json_body: { tools: @tools })
  end

  # @!method post_mcp(body)
  # Single JSON-RPC 2.0 endpoint implementing the MCP Streamable HTTP transport.
  #
  # Handles the +initialize+, +notifications/initialized+, +tools/list+ and
  # +tools/call+ methods. +tools/call+ dispatches to whichever {MCP_TOOL_CLASSES}
  # entry matches the requested tool name.
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

  # Dispatches a +tools/call+ request to the named tool's +call+ method and
  # wraps the result as MCP tool-call content. Any exception raised by the
  # tool (malformed input, a rejected query, an upstream failure, ...)
  # becomes a JSON-RPC error rather than a 500 - tools are trusted to raise
  # something with a useful +#message+, not to catch their own errors.
  #
  # @param id [Integer, String, nil] JSON-RPC request id
  # @param params [Hash] must contain +name+ and an +arguments+ hash
  # @return [String] JSON-RPC response
  def mcp_call_tool(id:, params:)
    tool_class = MCP_TOOL_CLASSES.find { |t| params['name'] == t::NAME }
    return mcp_error(id, -32_602, "Unknown tool: #{params['name']}") unless tool_class

    arguments = params['arguments'] || {}
    begin
      content = tool_class.call(arguments)
      mcp_result(id, { content: content }.to_json)
    rescue StandardError => e
      mcp_error(id, -32_000, "Query failed: #{e.message}")
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
