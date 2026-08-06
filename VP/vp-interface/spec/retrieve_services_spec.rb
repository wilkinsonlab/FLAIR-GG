# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'GET /flair-gg-vp-server/retrieve-services', type: :request do
  # Uses a *real* ServiceCollection (not a double) with only its two
  # network-touching methods stubbed out, so #minimize_service_collection and
  # the route's handling of it run for real. This is a regression test for a
  # bug found while refactoring routes.rb: the route called
  # ServiceCollection#vpgraph=, an attribute renamed to #endpoint upstream
  # (commit b0dd1a0) but never updated here - a plain double would not have
  # caught this, since it only responds to whatever the test tells it to.
  let(:service_collection) do
    allow_any_instance_of(ServiceCollection).to receive(:ontology_annotations).and_return('Format')
    allow_any_instance_of(ServiceCollection).to receive(:collect_similar_services) # no-op; leaves allservices == []
    ServiceCollection.new(endpoint: ENV.fetch('FDPSPARQL'), servicetype: 'http://edamontology.org/format_3790')
  end

  before do
    vp = stub_vp
    allow(vp).to receive(:retrieve_sevices)
      .with(termuri: 'http://edamontology.org/format_3790')
      .and_return([service_collection, {}, {}, '*/*'])
  end

  it 'returns a minimized service collection as JSON' do
    get '/flair-gg-vp-server/retrieve-services', { services: 'http://edamontology.org/format_3790' },
        { 'HTTP_ACCEPT' => 'application/json' }

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body['servicetype']).to eq('http://edamontology.org/format_3790')
    expect(body['services']).to eq([])
  end

  it 'renders the services_layout view for HTML requests' do
    get '/flair-gg-vp-server/retrieve-services', { services: 'http://edamontology.org/format_3790' },
        { 'HTTP_ACCEPT' => 'text/html' }

    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to include('text/html')
  end
end
