require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"
require_relative "bioregistry"
require_relative  "identifiers"
require_relative  "metadata_functions"
require_relative  "wordcloud"
require_relative  "ebi_ontology"
require_relative  "ebi_ontology_v3"
require_relative  "ontobee"
require_relative  "etsi"
require_relative  "bio2rdf"
require_relative  "ncbo"

# frozen_string_literal: false
class FDP
  attr_accessor :graph, :address, :called


  def initialize(address:, refresh: false)
    @address = address
    @graph = RDF::Graph.new
    @called = []

    if refresh
      load(address: address)
      freeze
    else
      thaw
    end
  end

  def ontology_annotations(uri:)
    # THE ONES WE CAN'T HANDLE ARE:
    # <https://bioregistry.io/api/reference/sio:SIO_001052 - doesn't generate usable URLs from bioregistry

    term = nil
    urls = pre_process_uri(uri: uri)
    warn "Final URL list #{urls}\n\n"
    urls.each do |uri|
      warn "processing #{uri}\n"
      if (match = uri.match(/etsi\.org/))  # done
        warn "ETSI"
        etsi = Etsi.new(uri: uri)
        term = etsi.lookup_title
      elsif uri =~ /HP_|ORDO|UBERON_|CHEMINF|DUO_/   
        # HPO terms redirect to JAX using ontobee, so they have to be treated separately
        # DUO terms redirect from ontobee to EBI
        warn "EBI"
        # |GO_|SIO_|UBERON_|ORDO|CMO_|/
        ebi = EBITerm.new(uri: uri)
        term = ebi.lookup_title # specific for EBI
      elsif (uri =~ /ols\/ontologies\/[^\/]+\/terms\?iri\=(\S+)/) # e.g. <https://www.ebi.ac.uk/ols/ontologies/edam/terms?iri=http://edamontology.org/data_1153
        warn "EBIOLS"
        uri = $1  # http://edamontology.org/data_1153
        ebi3 = EBITerm.new(uri: uri)
        term = ebi3.lookup_title
      elsif uri =~ /LNC/   # LNC terms redirect to NCBO bioontologies, so need to be given to the API
        warn "NCBO"
        ncbo = NCBO.new(uri: uri)
        term = ncbo.lookup_title # specific for EBI
      elsif uri =~ /^https?\:\/\/bio2rdf\.org/   # bio2rdf still works!
        warn "Bio2RDF"
        bio2rdf = Bio2RDF.new(uri: uri)
        term = bio2rdf.lookup_title # specific for EBI
      elsif (match = uri.match(/purl\.obolibrary\.org\/obo\/(\w+)/))
        warn "obolibrary"
        uri = "https://purl.obolibrary.org/obo/#{match[1]}"
        warn "obolibrary #{uri}"
        ob = Ontobee.new(uri: uri)
        term = ob.lookup_title
      elsif uri =~ /identifiers\.org/
        warn "ids.org"
        ido = IDsOrg.new(uri: uri)
        term = ido.lookup_title
      end
      break if term =~ /\W+ /
    end
    warn "term: #{term}"
    warn "found no match for #{uri}" unless term
    term
  end

  def pre_process_uri(uri:)
    synonym_urls = []
    if uri =~ /bioregistry\.io/
      br = BioRegistry.new(uri: uri)
      synonym_urls = br.synonym_urls
    elsif uri =~ /identifiers\.org/
      ido = IDsOrg.new(uri: uri)
      synonym_urls = ido.synonym_urls
    else 
      synonym_urls << uri
    end

    synonym_urls
  end

  def thaw
    address = Digest::SHA256.hexdigest @address
    begin
      RDF::Reader.open("./cache/#{address}.ttl") do |reader|
        reader.each_statement do |statement|
          @graph << statement
        end
      end
    rescue StandardError
      nil
    end
  end

  def freeze
    address = Digest::SHA256.hexdigest @address
    f = open("./cache/#{address}.ttl", "w")
    f.puts @graph.to_ttl
    f.close
  end

  def load(address:)
    return if called.include? address

    called << address
    address = address.gsub(%r{/$}, "")
    address += "/?format=ttl"
    warn "getting #{address}"
    begin
      r = RestClient.get(address)
    rescue
      warn "#{addres} didn't resolve"
    end
    if r 
      parse(message: r.body)
    end
  end

  def parse(message:)
    data = StringIO.new(message)
    RDF::Reader.for(:turtle).new(data) do |reader|
      reader.each_statement do |statement|
        @graph << statement
        if statement.predicate.to_s == "http://www.w3.org/ns/ldp#contains"
          contained_thing = statement.object.to_s
          self.load(address: contained_thing) # this ends up being recursive... careful!
        end
        # warn @graph.size
      end
    end
  end

  def find_discoverables
    vpd = SPARQL.parse("
    PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dc: <http://purl.org/dc/terms/>

    SELECT ?s ?t ?title WHERE
    { VALUES ?connection { ejp:vpConnection dcat:theme dcat:themeTaxonomy }

      ?s  ?connection ejp:VPDiscoverable ;
          dc:title ?title ;
          a ?t .}")
    discoverables = build_from_results(results: @graph.query(vpd))
    warn discoverables
    discoverables
  end

  def keyword_search(keyword: "")
    vpd = SPARQL.parse("
    PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dc: <http://purl.org/dc/terms/>

    SELECT ?s ?t ?title WHERE
    { VALUES ?connection { ejp:vpConnection dcat:theme dcat:themeTaxonomy }
      VALUES ?searchfields { dcat:keyword dc:title dc:description }

      ?s  ?connection ejp:VPDiscoverable ;
          dc:title ?title ;
          a ?t .

      ?s ?searchfields ?kw .
      FILTER(CONTAINS(lcase(?kw), lcase('#{keyword}')))
      }")
    discoverables = build_from_results(results: @graph.query(vpd))
    warn discoverables
    discoverables
  end

  def ontology_search(uri: "")
    warn "definitel in ontology search"
    vpd = SPARQL.parse("
    PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dc: <http://purl.org/dc/terms/>

    SELECT ?s ?t ?title WHERE
    { VALUES ?connection { ejp:vpConnection dcat:theme dcat:themeTaxonomy }
      VALUES ?annotation { dcat:theme dcat:themeTaxonomy }

      ?s  ?connection ejp:VPDiscoverable ;
          dc:title ?title ;
          a ?t .

      ?s ?annotation <#{uri}> .
      }")
    discoverables = build_from_results(results: @graph.query(vpd))
    warn discoverables
    discoverables
  end

  def match_type_to_icon(type:)
    t = type.match(%r{[\#/](\w+?)$})[1].downcase.to_sym
    warn "matching #{t}\n\n"
    hash = {
      biobank: "biobank.svg",
      catalog: "catalog.svg",
      dataservice: "dataservice.svg",
      dataset: "dataset.svg",
      registry: "registry.svg"
    }
    return hash[t] if hash[t]

    "unknown.svg"
  end

  def build_from_results(results:)
    discoverables = {}
    results.each do |result|
      next if result[:t].to_s =~ /\#Resource/

      icon = match_type_to_icon(type: result[:t].to_s)
      discoverables[result[:s].to_s] = { title: result[:title].to_s, type: result[:t].to_s, icon: icon }
    end
    discoverables
  end

  def get_verbose_annotations
    words = []
    vpd = SPARQL.parse("
    PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dc: <http://purl.org/dc/terms/>

    SELECT ?annot WHERE
    { VALUES ?annotation { dcat:theme dcat:themeTaxonomy }
      ?s  ?annotation ?annot .
      }")
    results = @graph.query(vpd)
    results.each do |res|
      uri = res[:annot].to_s
      word = ontology_annotations(uri: uri)
      words << word unless word&.empty?
    end
    # end of taxonomy parser

    warn "\n\nSWITCH TO KEYWORDS\n\n"
    vpd = SPARQL.parse("
    PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dc: <http://purl.org/dc/terms/>

    select ?kw WHERE
    { VALUES ?searchfields { dcat:keyword }
    ?s ?searchfields ?kw .
    }")
    results = @graph.query(vpd)
    results.each do |res|
      words << res[:kw].to_s
    end
    words.compact!
    warn "PROVIDER WORDS:  #{words}"
    words
  end
end
