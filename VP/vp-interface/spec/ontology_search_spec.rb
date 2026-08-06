# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'Ontology search routes', type: :request do
  let(:results) { [{ 'title' => 'Annotated Resource' }] }

  describe 'GET /flair-gg-vp-server/ontology-search' do
    it 'passes the raw uri param through to VP#ontology_search_shell' do
      vp = stub_vp
      expect(vp).to receive(:ontology_search_shell).with(term: 'http://edamontology.org/format_3790').and_return(results)

      get '/flair-gg-vp-server/ontology-search', { uri: 'http://edamontology.org/format_3790' },
          { 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq(results)
    end
  end

  describe 'POST /flair-gg-vp-server/ontology-search' do
    it 'reads uri from a JSON body, defaulting to an empty string' do
      vp = stub_vp
      expect(vp).to receive(:ontology_search_shell).with(term: 'edam:format_3790').and_return(results)

      post '/flair-gg-vp-server/ontology-search', { uri: 'edam:format_3790' }.to_json,
           { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
    end
  end
end
