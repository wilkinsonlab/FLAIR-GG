require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"

# frozen_string_literal: false
class FDP
  attr_accessor :graph, :address, :called

  FDPSITES = %w[https://zks-docker.ukl.uni-freiburg.de/fairdatapoint-euronmd/ https://fairdata.services:7070/
                https://fair.ciroco.org https://w3id.org/simpathic/fdp https://w3id.org/fairvasc-fdp/ https://w3id.org/ctsr-fdp https://w3id.org/smartcare-fdp]

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
      root = "https://www.ebi.ac.uk/ols4/api/ontologies/XXXXX/terms/"
      url = ""

      if uri =~ /bioregistry/
        # e.g. http://bioregistry.io/edam:data_1153
        uri = traverse_bioregistry(uri: uri)
      end

      next unless uri

      encoded = URI.encode_www_form_component uri
      encoded = URI.encode_www_form_component encoded

      if uri =~ /NCIT_/
        url = root.gsub("XXXXX", "ncit") + encoded
      elsif uri =~ /HP_/
        url = root.gsub("XXXXX", "hp") + encoded
      elsif uri =~ /GO_/
        url = root.gsub("XXXXX", "go") + encoded
      elsif uri =~ /SIO_/
        url = root.gsub("XXXXX", "sio") + encoded
      elsif uri =~ /UBERON_/
        url = root.gsub("XXXXX", "uberon") + encoded
      elsif uri =~ /ORDO/
        url = root.gsub("XXXXX", "ordo") + encoded
      elsif uri =~ /CMO_/
        url = root.gsub("XXXXX", "cmo") + encoded
      elsif uri =~ /ols\/ontologies/
        url = uri.gsub("ols/ontologies", "ols/api/ontologies")
      end
      warn "url is #{url}"
      if url.empty?
        warn "found no match for #{uri}"
        next
      end
      begin
        res = RestClient.get(url)
      rescue StandardError
        warn "HTTP CALL FAILED FOR #{url}"
        next
      end
      unless res
        warn "didn't resolve #{url}"
        next
      end
      begin
        j = JSON.parse(res.body)
      rescue
      end
      next unless j.is_a? Hash
      if j["_embedded"]
        warn "OLD STYLE OLS"
        warn "found word is #{j["_embedded"]["terms"][0]["label"].to_s}"
        words << j["_embedded"]["terms"][0]["label"].to_s
      elsif j["label"]
        warn "NEW STYLE OLS"
        warn "found word is #{j["label"].to_s}"
        words << j["label"].to_s 
      elsif j["annotation"]
        warn "OTHER NEW STYLE OLS"
        warn "found word is #{j["annotation"]["label"].to_s}"
        words << j["annotation"]["label"].to_s 
      else
        warn "CAN'T UNDERSTAND RESPONSE BODY"
      end
      warn "end of taxonomy parser"
    end # end of taxonomy parser

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

  def traverse_bioregistry(uri:)
    # e.g. http://bioregistry.io/edam:data_1153
    # https://bioregistry.io/api/reference/orphanet.ordo:83419
    # {
    #   "query": {
    #     "prefix": "ncit",
    #     "identifier": "C28421"
    #   },
    #   "providers": {
    #     "default": "http://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI%20Thesaurus&code=C28421",
    #     "bioregistry": "https://bioregistry.io/ncit:C28421",
    #     "miriam": "https://identifiers.org/ncit:C28421",
    #     "obofoundry": "http://purl.obolibrary.org/obo/NCIT_C28421",
    #     "ols": "https://www.ebi.ac.uk/ols4/ontologies/ncit/terms?iri=http://purl.obolibrary.org/obo/NCIT_C28421",
    #     "n2t": "https://n2t.net/ncit:C28421",
    #     "bioportal": "https://bioportal.bioontology.org/ontologies/NCIT/?p=classes&conceptid=http://purl.obolibrary.org/obo/NCIT_C28421",
    #     "bio2rdf": "http://bio2rdf.org/ncit:C28421",
    #     "evs": "http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#C28421"
    #   }
    # }# }
    term = uri.match(%r{.*/(\S+?)$})[1] # edam:data_1153
    bioreg = "https://bioregistry.io/api/reference/#{term}"
    warn "BIOREG #{bioreg}"
    resp = nil
    begin
      resp = RestClient.get(bioreg)
    rescue StandardError
      warn "\t\t\t\t\tRESCUING!!!!!!!!!!!!!!!!!!!!!!!!!"
      resp = nil
    end
    unless resp
      warn "NOTHING FOUND IN BIOREG"
      return nil
    end
    warn "BIOREG RESPONDED"
    j = JSON.parse(resp.body)
    url = j["providers"]["obofoundry"] || j["providers"]["default"]
    warn "DEFAULT provider #{url}"
    url
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
