# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'GET /flair-gg-vp-server/mcp', type: :request do
  it 'returns the tool catalogue as JSON, matching tools/list' do
    stub_vp
    get '/flair-gg-vp-server/mcp', {}, { 'HTTP_ACCEPT' => 'application/json' }
    body = JSON.parse(last_response.body)
    names = body['tools'].map { |t| t['name'] }
    expect(names).to eq(%w[keyword_search sparql_query iucn_endangerment_status])
  end

  it 'returns an HTML page when the browser asks for text/html' do
    stub_vp
    get '/flair-gg-vp-server/mcp', {}, { 'HTTP_ACCEPT' => 'text/html' }
    expect(last_response.content_type).to include('text/html')
    expect(last_response.body).to include('keyword_search')
    expect(last_response.body).to include('sparql_query')
    expect(last_response.body).to include('iucn_endangerment_status')
  end
end

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

  it 'lists the registered tools' do
    rpc('tools/list')
    body = JSON.parse(last_response.body)
    names = body['result']['tools'].map { |t| t['name'] }
    expect(names).to eq(%w[keyword_search sparql_query iucn_endangerment_status])
    keyword_tool = body['result']['tools'].find { |t| t['name'] == 'keyword_search' }
    expect(keyword_tool['inputSchema']['required']).to eq(['keyword'])
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

  it 'calls sparql_query and wraps the rows as MCP content' do
    stub_vp
    expect(VP).to receive(:execute_raw_sparql)
      .with(query: 'SELECT ?s WHERE { ?s ?p ?o }')
      .and_return([{ s: 'http://example.org/1' }])

    post '/flair-gg-vp-server/mcp',
         { jsonrpc: '2.0', id: 1, method: 'tools/call',
           params: { name: 'sparql_query', arguments: { query: 'SELECT ?s WHERE { ?s ?p ?o }' } } }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }

    body = JSON.parse(last_response.body)
    content = JSON.parse(body['result']['content'].first['text'])
    expect(content).to eq([{ 's' => 'http://example.org/1' }])
  end

  it 'returns a JSON-RPC error (not a 500) when sparql_query rejects a non-SELECT query' do
    stub_vp
    expect(VP).to receive(:execute_raw_sparql).and_raise(ArgumentError, 'Only SELECT queries are supported')

    post '/flair-gg-vp-server/mcp',
         { jsonrpc: '2.0', id: 1, method: 'tools/call',
           params: { name: 'sparql_query', arguments: { query: 'DELETE WHERE { ?s ?p ?o }' } } }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(200) # JSON-RPC errors are still HTTP 200
    body = JSON.parse(last_response.body)
    expect(body['error']['code']).to eq(-32_000)
    expect(body['error']['message']).to include('Only SELECT')
  end

  it 'calls iucn_endangerment_status and returns raw per-endpoint bodies, tolerating one failure' do
    service_a = instance_double(Service, endpoint: 'http://a.example.org/iucn')
    service_b = instance_double(Service, endpoint: 'http://b.example.org/iucn')
    servicecollection = instance_double(ServiceCollection, allservices: [service_a, service_b])

    stub_vp(
      retrieve_sevices: [servicecollection, {}, {}, '*/*'],
      guess_best_content_type: '*/*'
    )

    expect(Service).to receive(:execute_get)
      .with(endpoint: 'http://a.example.org/iucn', params: {}, accept: '*/*')
      .and_return(instance_double(RestClient::Response, body: 'raw a'))
    expect(Service).to receive(:execute_get)
      .with(endpoint: 'http://b.example.org/iucn', params: {}, accept: '*/*')
      .and_raise(StandardError, 'timeout')

    post '/flair-gg-vp-server/mcp',
         { jsonrpc: '2.0', id: 1, method: 'tools/call',
           params: { name: 'iucn_endangerment_status', arguments: {} } }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }

    body = JSON.parse(last_response.body)
    content = JSON.parse(body['result']['content'].first['text'])
    expect(content['http://a.example.org/iucn']).to eq('raw a')
    expect(content['http://b.example.org/iucn']).to eq({ 'error' => 'timeout' })
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
