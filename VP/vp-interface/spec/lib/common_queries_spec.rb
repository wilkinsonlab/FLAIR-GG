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

# .execute_raw_sparql backs the experimental sparql_query MCP tool
# (app/controllers/mcp_routes.rb), which lets an LLM author its own SPARQL
# query - so unlike the rest of common_queries.rb, the query text here is
# never something the app itself wrote. The safety net is entirely at the
# query-*form* level (SELECT only), not escaping, since there's no fixed
# template to inject into.
RSpec.describe 'VP.execute_raw_sparql' do
  let(:fake_client) { instance_double(SPARQL::Client) }

  before { allow(VP).to receive(:sparql_client).and_return(fake_client) }

  it 'rejects non-SELECT query forms' do
    expect { VP.execute_raw_sparql(query: 'ASK { ?s ?p ?o }') }.to raise_error(ArgumentError, /Only SELECT/)
  end

  it 'rejects update operations' do
    expect { VP.execute_raw_sparql(query: 'DELETE WHERE { ?s ?p ?o }') }.to raise_error(ArgumentError)
  end

  it 'allows a SELECT query preceded by PREFIX declarations' do
    allow(fake_client).to receive(:query).and_return([])
    expect do
      VP.execute_raw_sparql(query: 'PREFIX x: <http://x/> SELECT ?s WHERE { ?s ?p ?o }')
    end.not_to raise_error
  end

  it 'appends a default LIMIT when none is given' do
    captured = nil
    allow(fake_client).to receive(:query) do |q|
      captured = q
      []
    end

    VP.execute_raw_sparql(query: 'SELECT ?s WHERE { ?s ?p ?o }')

    expect(captured).to include('LIMIT 100')
  end

  it 'does not append a second LIMIT when one is already present' do
    captured = nil
    allow(fake_client).to receive(:query) do |q|
      captured = q
      []
    end

    VP.execute_raw_sparql(query: 'SELECT ?s WHERE { ?s ?p ?o } LIMIT 5')

    expect(captured.scan(/LIMIT/i).size).to eq(1)
  end

  it 'converts result rows to plain string-valued hashes' do
    solution = instance_double('RDF::Query::Solution', to_h: { s: 'http://example.org/1', label: 'Example' })
    allow(fake_client).to receive(:query).and_return([solution])

    rows = VP.execute_raw_sparql(query: 'SELECT ?s ?label WHERE { ?s rdfs:label ?label }')

    expect(rows).to eq([{ s: 'http://example.org/1', label: 'Example' }])
  end
end
