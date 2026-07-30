# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe VP do
  subject(:vp) { described_class.current_vp }

  describe '#normalize_ontology_term' do
    it 'leaves full HTTP URIs untouched' do
      expect(vp.normalize_ontology_term('http://edamontology.org/format_3790')).to eq('http://edamontology.org/format_3790')
    end

    it 'strips a CURIE prefix' do
      expect(vp.normalize_ontology_term('edam:format_3790')).to eq('format_3790')
    end

    it 'strips surrounding whitespace' do
      expect(vp.normalize_ontology_term('  edam:format_3790  ')).to eq('format_3790')
    end

    it 'handles nil without raising' do
      expect(vp.normalize_ontology_term(nil)).to eq('')
    end
  end

  describe '#build_service_label' do
    it 'downcases and replaces whitespace with underscores' do
      expect(vp.build_service_label('My Cool Service')).to eq('my_cool_service')
    end
  end

  describe '#notebook_url' do
    it 'builds the FLAIR-GG-Analytics notebook URL for a service label' do
      url = vp.notebook_url('my_cool_service')
      expect(url).to eq(
        'https://wilkinsonlab.github.io/FLAIR-GG-Analytics/lab/index.html?path=FLAIR-GG%2Fmy_cool_service.ipynb'
      )
    end
  end

  describe '#refresh_service_types' do
    it 'clears the service-type cache file before recollecting' do
      expect(FileUtils).to receive(:rm_f).with('./cache/servicetypes.json')
      expect(vp).to receive(:collect_data_services).and_return([%w[type label]])

      expect(vp.refresh_service_types).to eq([%w[type label]])
    end
  end
end
