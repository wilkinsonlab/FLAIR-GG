# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'Keyword search routes', type: :request do
  let(:results) { [{ 'title' => 'Matching Resource' }] }

  describe 'GET /flair-gg-vp-server/keyword-search' do
    it 'strips the keyword and delegates to VP#keyword_search_shell' do
      vp = stub_vp
      expect(vp).to receive(:keyword_search_shell).with(keyword: 'wheat').and_return(results)

      get '/flair-gg-vp-server/keyword-search', { keyword: '  wheat  ' }, { 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq(results)
    end
  end

  describe 'POST /flair-gg-vp-server/keyword-search' do
    it 'reads the keyword from a JSON body' do
      vp = stub_vp
      expect(vp).to receive(:keyword_search_shell).with(keyword: 'seed').and_return(results)

      post '/flair-gg-vp-server/keyword-search', { keyword: 'seed' }.to_json,
           { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq(results)
    end

    it 'treats a missing keyword as an empty string rather than raising' do
      vp = stub_vp
      expect(vp).to receive(:keyword_search_shell).with(keyword: '').and_return([])

      post '/flair-gg-vp-server/keyword-search', {}.to_json,
           { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
    end
  end
end
