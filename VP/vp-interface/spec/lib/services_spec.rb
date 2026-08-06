# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe 'ServiceCollection#collect_similar_services (lib/services.rb)' do
  after do
    OntologyAnnotationCache.instance_variable_set(:@data, nil)
    FileUtils.rm_f('./cache/ontology_annotations.json')
  end

  let(:oas3_doc) do
    {
      openapi: '3.0.0',
      info: { title: 'Test', version: '1' },
      servers: [{ url: 'https://example.org/api' }],
      paths: {
        '/repositories/test' => { get: { responses: { '200' => { description: 'ok' } } } }
      }
    }.to_json
  end

  # Service#retrieve_endpoint always fetches the OpenAPI doc, then always
  # passes it through the swagger-converter service before parsing - stub
  # both, with the converter as a passthrough (it no-ops on an already-OAS3
  # doc, same as the real one).
  def stub_openapi_fetch(url:, body:)
    stub_request(:get, url).to_return(status: 200, body: body)
    stub_request(:post, 'http://swagger-converter:8080/api/convert').to_return(status: 200, body: body)
  end

  it 'includes a matching provider with successful: true and no warning' do
    stub_openapi_fetch(url: 'https://example.org/openapi-match.json', body: oas3_doc)
    allow(VP).to receive(:collect_similar_services_query).and_return(
      [{ contact: 'https://provider.example.org/', title: 'Matching',
         openapi: 'https://example.org/openapi-match.json',
         endpoint: 'https://example.org/api/repositories/test' }]
    )

    collection = ServiceCollection.new(endpoint: ENV.fetch('FDPSPARQL'), servicetype: 'http://example.org/type')

    expect(collection.allservices.length).to eq(1)
    expect(collection.allservices.first.successful).to be(true)
    expect(collection.warnings).to be_empty
  end

  it 'still lists a non-matching provider (not excluded), flagged unsuccessful, with a warning' do
    stub_openapi_fetch(url: 'https://example.org/openapi-mismatch.json', body: oas3_doc)
    allow(VP).to receive(:collect_similar_services_query).and_return(
      [{ contact: 'https://provider.example.org/', title: 'Mismatched',
         openapi: 'https://example.org/openapi-mismatch.json',
         endpoint: 'https://example.org/api/repositories/DOES_NOT_EXIST' }]
    )

    collection = ServiceCollection.new(endpoint: ENV.fetch('FDPSPARQL'), servicetype: 'http://example.org/type')

    expect(collection.allservices.length).to eq(1)
    expect(collection.allservices.first.successful).to be(false)
    expect(collection.warnings.length).to eq(1)
    expect(collection.warnings.first).to include('could not be verified')
  end
end
