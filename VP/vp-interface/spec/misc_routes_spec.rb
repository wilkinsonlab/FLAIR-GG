# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'Redirects, refresh, and CORS routes', type: :request do
  before { stub_vp }

  describe 'GET /' do
    it 'redirects to the resources listing' do
      get '/'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to end_with('/flair-gg-vp-server/resources')
    end
  end

  describe 'GET /flair-gg-vp-server/force-refresh' do
    it 'redirects to /resources/force-refresh' do
      get '/flair-gg-vp-server/force-refresh'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to end_with('/flair-gg-vp-server/resources/force-refresh')
    end
  end

  describe 'GET /flair-gg-vp-server/resources/force-refresh' do
    after { FileUtils.rm_f('./cache/REFRESHING') }

    it 'refreshes resources and service types, then redirects to /resources' do
      vp = stub_vp
      expect(vp).to receive(:get_resources).and_return([])
      expect(vp).to receive(:refresh_service_types).and_return([])

      get '/flair-gg-vp-server/resources/force-refresh'

      expect(last_response.status).to eq(302)
      expect(last_response.location).to end_with('/flair-gg-vp-server/resources')
    end

    it 'skips the refresh entirely when ./cache/REFRESHING already exists' do
      FileUtils.touch('./cache/REFRESHING')
      vp = stub_vp
      expect(vp).not_to receive(:get_resources)
      expect(vp).not_to receive(:refresh_service_types)

      get '/flair-gg-vp-server/resources/force-refresh'

      expect(last_response.status).to eq(302)
    end
  end

  describe 'GET /flair-gg-vp-server/refresh-servicetypes' do
    it 'refreshes service types and redirects to /resources' do
      vp = stub_vp
      expect(vp).to receive(:refresh_service_types).and_return([])

      get '/flair-gg-vp-server/refresh-servicetypes'

      expect(last_response.status).to eq(302)
      expect(last_response.location).to end_with('/flair-gg-vp-server/resources')
    end
  end

  describe 'GET /flair-gg-vp-server/servicetypes' do
    it 'returns the refreshed service types as JSON' do
      vp = stub_vp
      expect(vp).to receive(:refresh_service_types).and_return([['http://example.org/Type', 'Type']])

      get '/flair-gg-vp-server/servicetypes', {}, { 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq([['http://example.org/Type', 'Type']])
    end

    it 'returns 406 without an acceptable content type' do
      stub_vp(refresh_service_types: [])
      get '/flair-gg-vp-server/servicetypes'
      expect(last_response.status).to eq(406)
    end
  end

  describe 'OPTIONS preflight' do
    it 'answers any path with CORS headers and 200' do
      options '/flair-gg-vp-server/anything-at-all'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Allow']).to include('OPTIONS')
    end
  end

  describe 'CORS header on every response' do
    it 'sets Access-Control-Allow-Origin on a normal request' do
      get '/flair-gg-vp-server'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end
end
