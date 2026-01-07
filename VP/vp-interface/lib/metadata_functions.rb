require 'json'
require 'linkeddata'

TYPEHASH = {
  'text/turtle' => :turtle,
  'application/ld+json' => :jsonld,
  'application/rdf+xml' => :rdfxml,
  'text/html' => :rdfa
}.freeze

QUERY1 = "select ?title where {|||SUBJECT||| ?p ?title . FILTER(CONTAINS(lcase(str(?p)), 'title'))}".freeze
QUERY2 = "select ?title where {|||SUBJECT||| ?p1 ?o . ?o ?p2 ?title .
          FILTER(CONTAINS(lcase(str(?p1)), 'name')) .
          FILTER(CONTAINS(lcase(str(?p2)), 'textvalue'))}".freeze
QUERY3 = 'select ?title where {|||SUBJECT||| <http://www.w3.org/2000/01/rdf-schema#label> ?title }'.freeze
QUERY4 = "select ?title where {|||SUBJECT||| ?p1 ?title .
          FILTER(CONTAINS(lcase(str(?p1)), 'name')) }".freeze
QUERY5 = 'select ?title where {|||SUBJECT||| <http://www.w3.org/2000/01/rdf-schema#label> ?title .}'.freeze
QUERY6 = 'select ?title where {|||SUBJECT||| <https://list.worldfloraonline.org/terms/fullName> ?title .}'.freeze

def resolve_url_to_jsonld(url:)
  graph = RDF::Graph.new
  begin
    r = RestClient.get(url)
  rescue StandardError
    warn "#{url} didn't resolve to HTML when trying for jsonld in HTML #{r}"
    return nil
  end
  # <script type="application/ld+json">
  body = r.body
  if (match = body.match(%r{<script\s+type="application/ld\+json">((.|\n|\r)*?)</script}))
    jsonld = match[1]
    jsonld = jsonld.encode(Encoding.find('UTF-8'), invalid: :replace, undef: :replace, replace: '')
    data = StringIO.new(jsonld.encode('UTF-8'))
    RDF::Reader.for(:jsonld).new(data) do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
  end
  graph
end

def resolve_url_to_json(url:, accept: 'application/json')
  # graph = RDF::Graph.new
  # type = TYPEHASH[accept] # e.g. :turtle  for the RDF reader

  begin
    r = RestClient::Request.execute(
      method: :get,
      url:,
      headers: { accept: }
    )
  rescue StandardError
    warn "#{url} didn't resolve when trying for #{accept} #{r}"
    r = RestClient::Request.execute(
      method: :get,
      url:,
      headers: { accept: }
    )
  end

  body = r.body
  body = body.encode(Encoding.find('UTF-8'), invalid: :replace, undef: :replace, replace: '')
  JSON.parse(body)
end

def resolve_url_to_rdf(url:, accept: 'text/turtle')
  graph = RDF::Graph.new
  type = TYPEHASH[accept] # e.g. :turtle  for the RDF reader

  warn "retrieving type: #{type}"
  begin
    r = RestClient::Request.execute(
      method: :get,
      url:,
      headers: { accept: }
    )
  rescue StandardError => e
    warn "#{url} didn't resolve when trying for #{accept} #{r} #{e.inspect}"
    return graph
  end

  body = r.body
  # warn "RETURNED BODY:  #{body}\n\n"
  body = body.encode(Encoding.find('UTF-8'), invalid: :replace, undef: :replace, replace: '')
  data = StringIO.new(body.encode('UTF-8'))
  # warn "READING DATA:  #{data}\n\n"
  begin
    RDF::Reader.for(type).new(data) do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
  rescue StandardError
    warn "This failed to parse as  #{accept} ... moving on"
  end
  warn "GRAPHSIZE:  #{graph.size}\n\n"
  graph
end

def ontology_annotations(uri:) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  # THE ONES WE CAN'T HANDLE ARE:
  # <https://bioregistry.io/api/reference/sio:SIO_001052 - doesn't generate usable URLs from bioregistry

  term = nil
  urls = pre_process_uri(uri:)
  warn "Final URL list #{urls}\n\n"
  urls.each do |url| # rubocop:disable Metrics/BlockLength
    warn "processing #{url}\n"
    if (match = url.match(/etsi\.org/)) # done
      warn 'ETSI'
      etsi = Etsi.new(uri: url)
      term = etsi.lookup_title
    elsif url =~ /edamontology/
      warn 'EDAM'
      edam = EDAM.new(uri: url)
      term = edam.lookup_title
    elsif url =~ /HP_|ORDO|UBERON_|CHEMINF|DUO_/
      # HPO terms redirect to JAX using ontobee, so they have to be treated separately
      # DUO terms redirect from ontobee to EBI
      warn 'EBI'
      # |GO_|SIO_|UBERON_|ORDO|CMO_|/
      ebi = EBITerm.new(uri: url)
      term = ebi.lookup_title # specific for EBI
    elsif url =~ %r{ols/ontologies/[^/]+/terms\?iri=(\S+)} # e.g. <https://www.ebi.ac.uk/ols/ontologies/edam/terms?iri=http://edamontology.org/data_1153
      warn 'EBIOLS'
      url = Regexp.last_match(1) # http://edamontology.org/data_1153
      ebi3 = EBITerm.new(uri: url)
      term = ebi3.lookup_title
    elsif url =~ /LNC/ # LNC terms redirect to NCBO bioontologies, so need to be given to the API
      warn 'NCBO'
      ncbo = NCBO.new(uri: url)
      term = ncbo.lookup_title # specific for EBI
    elsif url =~ %r{^https?://bio2rdf\.org} # bio2rdf still works!
      warn 'Bio2RDF'
      bio2rdf = Bio2RDF.new(uri: url)
      term = bio2rdf.lookup_title # specific for EBI
    elsif (match = url.match(%r{purl\.obolibrary\.org/obo/(\w+)}))
      warn 'obolibrary'
      url = "https://purl.obolibrary.org/obo/#{match[1]}"
      warn "obolibrary #{url}"
      ob = Ontobee.new(uri: url)
      term = ob.lookup_title
    elsif url =~ /identifiers\.org/
      warn 'ids.org'
      ido = IDsOrg.new(uri: url)
      term = ido.lookup_title
    elsif url =~ /schema\.org/
      warn 'schema.org'
      term = SchemaOrg.new(uri: url).term
    elsif url =~ /inspire\.ec/
      warn 'Inspire'
      insp = Inspire.new(uri: url)
      term = insp.lookup_title
    elsif url =~ /worldfloraonline/
      warn 'WFO'
      wfo = WFO.new(uri: url)
      term = wfo.lookup_title
    end
    break if term =~ /\w+/
  end
  unless term
    uri =~ %r{[\#/](\w+)\s*$}
    warn 'just a URL'
    term = Regexp.last_match(1)
  end
  warn "term: #{term}"
  warn "found no match for #{uri}" unless term
  term
end

def pre_process_uri(uri:)
  synonym_urls = []
  if uri =~ /bioregistry\.io/
    br = BioRegistry.new(uri:)
    synonym_urls = br.synonym_urls
  elsif uri =~ /identifiers\.org/
    ido = IDsOrg.new(uri:)
    synonym_urls = ido.synonym_urls
  else
    synonym_urls << uri
  end

  synonym_urls
end
