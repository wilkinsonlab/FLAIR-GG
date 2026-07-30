# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'POST /flair-gg-vp-server/mcp', type: :request do
  def rpc(method, params = {}, id = 1)
    stub_vp # every request still passes through the `before` filter
    post '/flair-gg-vp-server/mcp', { jsonrpc: '2.0', id: id, method: method, params: params }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }
  end

  it 'responds to initialize with protocol info' do
    rpc('initialize')
    body = JSON.parse(last_response.body)
    expect(body['result']['protocolVersion']).to eq(VPRoutes::MCP_PROTOCOL_VERSION)
    expect(body['result']['serverInfo']['name']).to eq('flair-gg-vp-server')
  end

  it 'lists the keyword_search tool' do
    rpc('tools/list')
    body = JSON.parse(last_response.body)
    tool = body['result']['tools'].first
    expect(tool['name']).to eq('keyword_search')
    expect(tool['inputSchema']['required']).to eq(['keyword'])
  end

  it 'calls keyword_search and wraps the result as MCP content' do
    vp = stub_vp
    expect(vp).to receive(:keyword_search_shell).with(keyword: 'cancer').and_return([{ 'title' => 'Match' }])

    post '/flair-gg-vp-server/mcp',
         { jsonrpc: '2.0', id: 1, method: 'tools/call',
           params: { name: 'keyword_search', arguments: { keyword: 'cancer' } } }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }

    body = JSON.parse(last_response.body)
    content = JSON.parse(body['result']['content'].first['text'])
    expect(content).to eq([{ 'title' => 'Match' }])
  end

  it 'returns a JSON-RPC error for an unknown tool' do
    rpc('tools/call', { name: 'not_a_real_tool', arguments: {} })
    body = JSON.parse(last_response.body)
    expect(body['error']['code']).to eq(-32_602)
  end

  it 'returns a JSON-RPC error for an unknown method' do
    rpc('not/a/real/method')
    body = JSON.parse(last_response.body)
    expect(body['error']['code']).to eq(-32_601)
  end
end
