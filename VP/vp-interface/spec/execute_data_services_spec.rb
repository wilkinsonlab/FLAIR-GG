# frozen_string_literal: false

require_relative 'spec_helper'

RSpec.describe 'POST /flair-gg-vp-server/execute-data-services', type: :request do
  # build_service_label/notebook_url are pure functions (already unit-tested
  # in spec/lib/vp_spec.rb); here we just need *a* working implementation on
  # the double so the route's composition of them can be exercised.
  def stub_label_helpers(vp_double)
    allow(vp_double).to receive(:build_service_label) { |name| name.to_s.downcase.gsub(/\s+/, '_') }
    allow(vp_double).to receive(:notebook_url) do |label|
      "https://wilkinsonlab.github.io/FLAIR-GG-Analytics/lab/index.html?path=FLAIR-GG%2F#{label}.ipynb"
    end
  end

  describe 'Mode 1 - JSON API' do
    it 'builds the service label/analytics URL from uri and returns location, jupyter, results' do
      vp = stub_vp
      stub_label_helpers(vp)
      expect(vp).to receive(:execute_data_services_api)
        .with(json: hash_including('uri' => 'http://edamontology.org/operation_3436'))
        .and_return(['http://ldp.example.org/upload/1', { 'http://ep' => 'body' }])

      body = { uri: 'http://edamontology.org/operation_3436', service_list: ['http://ep'] }.to_json
      post '/flair-gg-vp-server/execute-data-services', body,
           { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed['location']).to eq('http://ldp.example.org/upload/1')
      expect(parsed['jupyter']).to eq(
        'https://wilkinsonlab.github.io/FLAIR-GG-Analytics/lab/index.html?path=FLAIR-GG%2Foperation_3436.ipynb'
      )
      expect(parsed['results']).to eq({ 'http://ep' => 'body' })
    end

    it 'accepts a single-element array body, unwrapping it' do
      vp = stub_vp
      stub_label_helpers(vp)
      expect(vp).to receive(:execute_data_services_api).and_return(['loc', {}])

      body = [{ uri: 'http://x/op', service_list: [] }].to_json
      post '/flair-gg-vp-server/execute-data-services', body,
           { 'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
    end
  end

  describe 'Mode 2 - HTML form' do
    it 'builds the service label from servicelabel and returns location/jupyter as JSON' do
      vp = stub_vp
      stub_label_helpers(vp)
      expect(vp).to receive(:execute_data_services).and_return(['http://ldp.example.org/upload/2', {}])

      post '/flair-gg-vp-server/execute-data-services', { servicelabel: 'My Cool Service' },
           { 'HTTP_ACCEPT' => 'application/json' }

      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed['location']).to eq('http://ldp.example.org/upload/2')
      expect(parsed['jupyter']).to eq('my_cool_service')
    end

    it 'renders execution_results_layout for HTML requests' do
      vp = stub_vp(execute_data_services: ['http://ldp.example.org/upload/3', {}])
      stub_label_helpers(vp)

      post '/flair-gg-vp-server/execute-data-services', { servicelabel: 'My Cool Service' },
           { 'HTTP_ACCEPT' => 'text/html' }

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/html')
    end
  end
end
