# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe 'lib/cache.rb (top-level cache helpers)' do
  after do
    FileUtils.rm_f('./cache/keywords.json')
    FileUtils.rm_f('./cache/servicetypes.json')
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
end
