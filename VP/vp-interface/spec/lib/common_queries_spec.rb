# frozen_string_literal: false

require_relative '../spec_helper'

# Regression tests for a SPARQL injection vulnerability: keyword/uri/termuri
# used to be interpolated straight into query strings with no escaping,
# meaning a value containing e.g. a `"` could break out of the intended
# string literal and inject arbitrary SPARQL. Now flowing through this
# escaping/validation, exercised without needing a real SPARQL endpoint.
RSpec.describe 'VP query-building SPARQL escaping' do
  describe '.escape_sparql_literal' do
    it 'leaves ordinary text untouched' do
      expect(VP.escape_sparql_literal('wheat')).to eq('wheat')
    end

    it 'escapes double quotes so they cannot close the string literal early' do
      escaped = VP.escape_sparql_literal('") } UNION { ?s ?p ?o } FILTER(true')
      # Every quote in the escaped output must be backslash-escaped - none may
      # stand alone and close the "..." literal early.
      expect(escaped).not_to match(/(?<!\\)"/)
      # The whole payload must survive as inert text inside one "..." literal.
      fragment = "FILTER(CONTAINS(LCASE(str(?kw)), LCASE(\"#{escaped}\")))"
      expect(fragment.scan(/(?<!\\)"/).size).to eq(2) # only the literal's own opening/closing quotes
    end

    it 'escapes backslashes' do
      expect(VP.escape_sparql_literal('back\\slash')).to eq('back\\\\slash')
    end

    it 'escapes embedded newlines and carriage returns' do
      expect(VP.escape_sparql_literal("a\nb\rc")).to eq('a\\nb\\rc')
    end
  end

  describe '.safe_sparql_iri?' do
    it 'accepts a normal HTTP(S) URI' do
      expect(VP.safe_sparql_iri?('http://edamontology.org/format_3790')).to be true
    end

    it 'rejects a value that would close the IRIREF early' do
      expect(VP.safe_sparql_iri?('http://x/> . DROP ALL ; #')).to be false
    end

    it 'rejects embedded whitespace and control characters' do
      expect(VP.safe_sparql_iri?("http://x/\ny")).to be false
    end
  end

  describe 'find_discoverables_query' do
    it 'never lets a keyword injection widen the query beyond one FILTER call' do
      vp = VP.current_vp
      captured_query = nil
      fake_client = instance_double(SPARQL::Client)
      allow(fake_client).to receive(:query) { |q| captured_query = q }
      allow(VP).to receive(:sparql_client).and_return(fake_client)

      vp.find_discoverables_query(endpoint: 'http://fdpindex.test/search/sparql',
                                  keyword: '") } UNION { ?s ?p ?o } FILTER(true')

      expect(captured_query).to include(
        'FILTER(CONTAINS(LCASE(str(?kw)), LCASE("\\") } UNION { ?s ?p ?o } FILTER(true")))'
      )
    end
  end

  describe '.collect_similar_services_query' do
    it 'raises rather than interpolating an unsafe termuri into the IRIREF' do
      expect do
        VP.collect_similar_services_query(endpoint: 'http://fdpindex.test/search/sparql',
                                          termuri: 'http://x/> . DROP ALL ; #')
      end.to raise_error(ArgumentError)
    end
  end
end
