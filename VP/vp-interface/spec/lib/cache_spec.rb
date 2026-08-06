# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe 'lib/cache.rb (top-level cache helpers)' do
  after do
    FileUtils.rm_f('./cache/keywords.json')
    FileUtils.rm_f('./cache/servicetypes.json')
    FileUtils.rm_f('./cache/ontology_annotations.json')
  end

  describe 'keywords cache' do
    it 'round-trips through freeze_keywords/thaw_keywords' do
      freeze_keywords(words: %w[seed wheat])
      expect(thaw_keywords).to eq(%w[seed wheat])
    end
  end

  describe 'service types cache' do
    it 'round-trips through freeze_servicetypes/thaw_servicetypes' do
      freeze_servicetypes(types: [['http://example.org/Type', 'Type']])
      expect(thaw_servicetypes).to eq([['http://example.org/Type', 'Type']])
    end
  end

  describe 'ontology annotations cache' do
    it 'round-trips through freeze_ontology_annotations/thaw_ontology_annotations' do
      freeze_ontology_annotations(cache: { 'http://example.org/term' => 'Term' })
      expect(thaw_ontology_annotations).to eq({ 'http://example.org/term' => 'Term' })
    end

    it 'returns an empty hash when no cache file exists yet' do
      expect(thaw_ontology_annotations).to eq({})
    end
  end
end
