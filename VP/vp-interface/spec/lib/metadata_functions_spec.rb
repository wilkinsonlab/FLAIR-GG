# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe 'ontology_annotations caching (lib/metadata_functions.rb)' do
  before { OntologyAnnotationCache.instance_variable_set(:@data, nil) }

  after do
    OntologyAnnotationCache.instance_variable_set(:@data, nil)
    FileUtils.rm_f('./cache/ontology_annotations.json')
  end

  it 'resolves a URI once, then serves repeat lookups from the in-process cache' do
    allow(self).to receive(:resolve_ontology_annotation).and_return('Resolved Term')

    expect(ontology_annotations(uri: 'http://example.org/term')).to eq('Resolved Term')
    expect(ontology_annotations(uri: 'http://example.org/term')).to eq('Resolved Term')

    expect(self).to have_received(:resolve_ontology_annotation).once
  end

  it 'persists a resolved URI to disk so a fresh process-wide cache skips re-resolving it' do
    allow(self).to receive(:resolve_ontology_annotation).and_return('Resolved Term')
    ontology_annotations(uri: 'http://example.org/term')

    OntologyAnnotationCache.instance_variable_set(:@data, nil) # simulate a fresh process

    expect(ontology_annotations(uri: 'http://example.org/term')).to eq('Resolved Term')
    expect(self).to have_received(:resolve_ontology_annotation).once
  end

  it 'does not cache a nil resolution, so a genuinely unresolvable URI is retried next time' do
    allow(self).to receive(:resolve_ontology_annotation).and_return(nil)

    ontology_annotations(uri: 'http://example.org/unresolvable')
    ontology_annotations(uri: 'http://example.org/unresolvable')

    expect(self).to have_received(:resolve_ontology_annotation).twice
  end
end
