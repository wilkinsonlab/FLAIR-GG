require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"

# frozen_string_literal: false
class FDP
  attr_accessor :graph, :address, :called

  FDPSITES = get_active_sites(index: 'https://index.vp.ejprarediseases.org/index/entries/all')

  # %w[https://zks-docker.ukl.uni-freiburg.de/fairdatapoint-euronmd/ https://fairdata.services:7070/
  #               https://fair.ciroco.org https://w3id.org/simpathic/fdp https://w3id.org/fairvasc-fdp/ https://w3id.org/ctsr-fdp https://w3id.org/smartcare-fdp]

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

  def get_active_sites(index:)
    r = RestClient.get(index, headers: {accept: "application/json"})
    # {
    #   "uuid": "48a1f752-8a60-4e40-a4bf-fc5e158f28f9",
    #   "clientUrl": "https://fdp.wikipathways.org/",
    #   "state": "ACTIVE",
    #   "registrationTime": "2023-07-04T14:36:52.885Z",
    #   "modificationTime": "2023-08-08T00:40:37.410Z"
    # },
    active_sites = JSON.parse(r.body).select {|s| s['state']=="ACTIVE"}
    active_sites
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
    r = RestClient.get(address)
    # warn r
    parse(message: r)
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
      words << word if word
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
    warn "PROVIDER WORDS:  #{words}"
    words
  end

  def ontology_annotations(uri:)
    if uri =~ /bioregistry/
      br = BioRegistry.new(uri: uri)
      # e.g. http://bioregistry.io/edam:data_1153
      term = br.lookup
    elsif uri =~ /NCIT_|HP_|GO_|SIO_|UBERON_|ORDO|CMO_|/
      ebi = EBITerm.new(uri: uri)
      term = ebi.lookup
    elsif uri =~ /ols\/ontologies/
      uri = uri.gsub("ols/ontologies", "ols/api/ontologies")
      ebi = EBITerm.new(uri: uri)
      term = ebi.lookup
    elsif uri =~ /identifiers\.org/
      ido = IDsOrg.new(uri: uri)
      term = ido.lookup
    end

    unless term
      warn "found no match for #{uri}"
      next
    end
    return term

  end

end

class Wordcloud
  attr_accessor :words

  def initialize(refresh: false)
    return if File.exist?("./cache/REFRESHING") # multiple browser calls are a problem!

    if File.exist?("./cache/keywords.json") && (refresh == "false")
      thaw
    else
      f = open("./cache/REFRESHING", "w")  # multiple browser calls are a problem!
      f.puts "REFRESHING"
      f.close
      
      fdps = FDP::FDPSITES
      @words = []
      fdps.each do |fdp|
        warn "\n\n\nQUERYING #{fdp}\n\n\n"
        site = FDP.new(address: fdp)
        @words << site.get_verbose_annotations
      end
      warn "flattening"
      @words = @words.flatten
      warn "\n\nWORDS\n\n#{@words}"
      freeze

      File.delete("./cache/REFRESHING")
    end
  end

  def count_words
    freqs = {}
    @words.each do |w|
      freq = @words.count(w)
      freqs[w] = freq
    end
    warn freqs
    freqs
  end

  def thaw
    kwf = File.open("./cache/keywords.json", "r")
    kw = kwf.read
    @words = JSON.parse(kw)
  rescue StandardError
    nil
  end

  def freeze
    f = open("./cache/keywords.json", "w")
    f.puts @words.to_json
    f.close
  end
end
