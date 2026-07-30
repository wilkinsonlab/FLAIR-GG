# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe Wordcloud do
  after do
    FileUtils.rm_f('./cache/keywords.json')
    FileUtils.rm_f('./cache/WCREFRESHING')
  end

  describe '#count_words' do
    it 'counts word frequency in O(n) without mutating the observable result' do
      wc = described_class.allocate
      wc.words = %w[seed seed wheat seed wheat]
      expect(wc.count_words).to eq({ 'seed' => 3, 'wheat' => 2 })
    end

    it 'returns an empty hash for no words' do
      wc = described_class.allocate
      wc.words = []
      expect(wc.count_words).to eq({})
    end
  end

  describe '.refreshing?' do
    it 'is false when no lock file exists' do
      FileUtils.rm_f('./cache/WCREFRESHING')
      expect(described_class.refreshing?).to be false
    end

    it 'is true once the lock file exists' do
      FileUtils.touch('./cache/WCREFRESHING')
      expect(described_class.refreshing?).to be true
    end
  end

  describe '#initialize' do
    it 'reads from the keyword cache when present and refresh is not requested' do
      File.write('./cache/keywords.json', %w[cached_word].to_json)
      expect(VP).not_to receive(:current_vp)

      wc = described_class.new
      expect(wc.words).to eq(['cached_word'])
    end

    it 'fetches fresh annotations and (re)writes the cache when refresh: true' do
      FileUtils.rm_f('./cache/keywords.json')
      vp = instance_double(VP, verbose_annotations: %w[fresh_word])
      allow(VP).to receive(:current_vp).and_return(vp)

      wc = described_class.new(refresh: true)

      expect(wc.words).to eq(['fresh_word'])
      expect(JSON.parse(File.read('./cache/keywords.json'))).to eq(['fresh_word'])
      expect(File.exist?('./cache/WCREFRESHING')).to be false
    end
  end
end
