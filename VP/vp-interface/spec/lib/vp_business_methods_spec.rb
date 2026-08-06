# frozen_string_literal: false

require_relative '../spec_helper'

# Unit specs for VP's core business logic, using the *real* VP.current_vp
# singleton (built once at boot with an empty FDPSITES list - see
# spec_helper.rb) with only the network-touching *_query methods and the
# top-level helpers from lib/cache.rb / lib/metadata_functions.rb stubbed.
# This exercises the real caching/branching/aggregation logic in lib/vp.rb
# without any real SPARQL or HTTP calls.
RSpec.describe VP do
  subject(:vp) { described_class.current_vp }

  def fdp_row(overrides = {})
    {
      resource: 'http://example.org/dataset/1', resourceName: 'Example Dataset',
      resourceTypeURI: 'https://w3id.org/fdp/fdp-o#Distribution', ServiceType: '',
      contact: 'http://example.org/contact'
    }.merge(overrides)
  end

  describe '#keyword_search' do
    it 'downcases the keyword and returns Discoverables built from the query results' do
      expect(vp).to receive(:find_discoverables_query)
        .with(endpoint: VPConfig::FDPSPARQL, keyword: 'wheat').and_return([fdp_row])

      results = vp.keyword_search(keyword: 'WHEAT')
      expect(results.map(&:title)).to eq(['Example Dataset'])
    end
  end

  describe '#ontology_search' do
    it 'delegates to find_discoverables_query with the given uri' do
      expect(vp).to receive(:find_discoverables_query)
        .with(endpoint: VPConfig::FDPSPARQL, uri: 'http://edamontology.org/format_3790').and_return([fdp_row])

      results = vp.ontology_search(uri: 'http://edamontology.org/format_3790')
      expect(results.size).to eq(1)
    end
  end

  describe '#build_from_results' do
    it 'skips rows typed only as #Resource' do
      row = fdp_row(resourceTypeURI: 'http://www.w3.org/ns/dcat#Resource')
      expect(vp.build_from_results(results: [row])).to eq([])
    end

    it 'skips dataservice rows with no ServiceType (they are top-level FDPs)' do
      row = fdp_row(resourceTypeURI: 'http://www.w3.org/ns/dcat#DataService', ServiceType: '')
      expect(vp.build_from_results(results: [row])).to eq([])
    end

    it 'builds a Discoverable for a normal row' do
      discoverables = vp.build_from_results(results: [fdp_row])
      expect(discoverables.size).to eq(1)
      expect(discoverables.first.title).to eq('Example Dataset')
      expect(discoverables.first.typetag).to eq('distribution')
    end
  end

  describe '#match_type_to_icon' do
    it 'maps a known type to its icon' do
      expect(vp.match_type_to_icon(type: 'https://w3id.org/fdp/fdp-o#Dataset')).to eq('dataset.svg')
    end

    it 'falls back to unknown.svg for an unrecognized type' do
      expect(vp.match_type_to_icon(type: 'https://example.org/SomethingElse')).to eq('unknown.svg')
    end
  end

  describe '#guess_best_content_type' do
    it 'maps the known CSV format term' do
      expect(vp.guess_best_content_type(termuri: 'http://edamontology.org/format_3790')).to eq('text/csv')
    end

    it 'defaults to */* for unknown terms' do
      expect(vp.guess_best_content_type(termuri: 'http://example.org/unknown')).to eq('*/*')
    end
  end

  describe '#collect_data_services' do
    after { FileUtils.rm_f('./cache/servicetypes.json') }

    it 'thaws from cache when the cache file exists' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('./cache/servicetypes.json').and_return(true)
      expect(vp).to receive(:thaw_servicetypes).and_return([['http://example.org/Type', 'Type']])
      expect(vp).not_to receive(:collect_data_services_query)

      expect(vp.collect_data_services).to eq([['http://example.org/Type', 'Type']])
    end

    it 'queries and freezes the cache when no cache file exists' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('./cache/servicetypes.json').and_return(false)
      expect(vp).to receive(:collect_data_services_query)
        .with(endpoint: VPConfig::FDPSPARQL)
        .and_return([{ type: 'http://example.org/Type' }])
      expect(vp).to receive(:ontology_annotations).with(uri: 'http://example.org/Type').and_return('Type')
      expect(vp).to receive(:freeze_servicetypes).with(types: [['http://example.org/Type', 'Type']])

      expect(vp.collect_data_services).to eq([['http://example.org/Type', 'Type']])
    end
  end

  describe '#execute_data_services' do
    it 'returns [nil, nil] when no endpoints are checked' do
      expect(vp.execute_data_services(params: {})).to eq([nil, nil])
    end

    it 'GETs each endpoint (no _request_body) and uploads the aggregated results' do
      params = { 'endpoint' => ['http://ep1'], 'accept' => 'application/json' }
      result = instance_double('RestClient::Response', body: 'the body')
      expect(Service).to receive(:execute_get)
        .with(endpoint: 'http://ep1', params: {}, accept: 'application/json').and_return(result)
      expect(vp).to receive(:process_and_upload_output)
        .with(results: { 'http://ep1' => 'the body' }).and_return('http://ldp.example.org/upload')

      expect(vp.execute_data_services(params: params)).to eq(['http://ldp.example.org/upload',
                                                              { 'http://ep1' => 'the body' }])
    end

    it 'POSTs each endpoint when _request_body is present' do
      params = { 'endpoint' => ['http://ep1'], '_request_body' => '{"a":1}' }
      result = instance_double('RestClient::Response', body: 'posted body')
      expect(Service).to receive(:execute_post).with(endpoint: 'http://ep1', body: params).and_return(result)
      expect(vp).to receive(:process_and_upload_output).and_return('http://ldp.example.org/upload')

      expect(vp.execute_data_services(params: params)).to eq(['http://ldp.example.org/upload',
                                                              { 'http://ep1' => 'posted body' }])
    end
  end

  describe '#execute_data_services_api' do
    it 'GETs each endpoint in service_list and uploads the aggregated results' do
      json = { 'service_list' => ['http://ep1'], 'accept' => 'application/json' }
      result = instance_double('RestClient::Response', body: 'the body')
      expect(Service).to receive(:execute_get).with(endpoint: 'http://ep1', params: {}, accept: 'application/json')
                                              .and_return(result)
      expect(vp).to receive(:process_and_upload_output)
        .with(results: { 'http://ep1' => 'the body' }).and_return('http://ldp.example.org/upload')

      expect(vp.execute_data_services_api(json: json)).to eq(
        ['http://ldp.example.org/upload', { 'http://ep1' => 'the body' }]
      )
    end
  end
end
