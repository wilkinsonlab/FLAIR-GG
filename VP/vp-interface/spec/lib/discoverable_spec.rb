# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe Discoverable do
  let(:attrs) do
    { source: 'http://example.org/contact', resource: 'http://example.org/res/unique-1',
      title: 'Unique Test Resource', type: 'http://schema.org/Dataset', icon: 'dataset.svg',
      typetag: 'dataset' }
  end

  describe '#to_json' do
    it 'serializes all attributes as real fields, not a Ruby object-inspect string' do
      json = JSON.parse(described_class.new(**attrs).to_json)
      # #contact is derived from #source in the constructor, not a passed-in attribute.
      expect(json).to eq(attrs.transform_keys(&:to_s).transform_values(&:to_s).merge('contact' => attrs[:source]))
    end
  end

  describe '.create_or_retrieve' do
    it 'returns the same instance for a repeated source+resource pair instead of duplicating' do
      first = described_class.create_or_retrieve(**attrs)
      second = described_class.create_or_retrieve(**attrs)
      expect(second).to equal(first)
    end

    it 'creates a new instance for a different resource' do
      first = described_class.create_or_retrieve(**attrs)
      second = described_class.create_or_retrieve(**attrs.merge(resource: 'http://example.org/res/unique-2'))
      expect(second).not_to equal(first)
    end
  end

  describe '.find_by_type' do
    it 'finds only instances matching the given type' do
      described_class.create_or_retrieve(**attrs.merge(resource: 'http://example.org/res/unique-3'))
      matches = described_class.find_by_type(type: attrs[:type])
      expect(matches).to include(an_object_having_attributes(resource: 'http://example.org/res/unique-3'))
    end
  end
end
