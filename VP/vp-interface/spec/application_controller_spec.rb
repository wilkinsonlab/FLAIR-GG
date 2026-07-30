# frozen_string_literal: false

require_relative 'spec_helper' # this will load the app

RSpec.describe 'ApplicationController', type: :request do
  describe 'GET /flair-gg-vp-server/resources' do
    let(:discoverable) do
      Discoverable.new(source: 'http://example.org', resource: 'http://example.org/res', title: 'Test Resource',
                       type: 'http://schema.org/Dataset', icon: 'dataset.svg', typetag: 'dataset')
    end

    before { stub_vp(get_resources: [discoverable]) }

    it 'returns 406 when no acceptable content type is requested' do
      get '/flair-gg-vp-server/resources'
      expect(last_response.status).to eq(406)
    end

    it 'returns the discoverables as JSON when Accept: application/json' do
      get '/flair-gg-vp-server/resources', {}, { 'HTTP_ACCEPT' => 'application/json' }
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('application/json')
      expect(JSON.parse(last_response.body).first['title']).to eq('Test Resource')
    end

    it 'renders the discovered_layout view when Accept: text/html' do
      get '/flair-gg-vp-server/resources', {}, { 'HTTP_ACCEPT' => 'text/html' }
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/html')
    end
  end

  describe 'GET /flair-gg-vp-server' do
    it 'returns the Swagger/OpenAPI root document' do
      stub_vp
      get '/flair-gg-vp-server'
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('application/json')
    end
  end
end
