require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"

# frozen_string_literal: false
class FDP
  attr_accessor :graph, :address, :called
  FDPSITES = %w[https://zks-docker.ukl.uni-freiburg.de/fairdatapoint-euronmd/ https://fairdata.services:7070/ https://fair.ciroco.org https://w3id.org/simpathic/fdp https://w3id.org/fairvasc-fdp/ https://w3id.org/ctsr-fdp https://w3id.org/smartcare-fdp ]

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
    t = type.match(/[\#\/](\w+?)$/)[1].downcase.to_sym
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

  def build_from_results(results: )
    discoverables = {}
    results.each do |result|
      next if result[:t].to_s =~ /\#Resource/

      icon = match_type_to_icon(type: result[:t].to_s )
      discoverables[result[:s].to_s] = { title: result[:title].to_s, type: result[:t].to_s, icon: icon }
    end
    return discoverables
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
      }"
    )
    results = @graph.query(vpd)
    results.each do |res|
      uri = res[:annot].to_s
      encoded = URI.encode_www_form_component uri
      encoded = URI.encode_www_form_component encoded
      root = "https://www.ebi.ac.uk/ols4/api/ontologies/XXXXX/terms/"
      url = ""
      case
      when uri =~ /NCIT_/
        url = root.gsub(/XXXXX/, "ncit") + encoded
      when uri =~ /HP_/
        url = root.gsub(/XXXXX/, "hp") + encoded
      when uri =~ /GO_/
        url = root.gsub(/XXXXX/, "go") + encoded
      when uri =~ /SIO_/
        url = root.gsub(/XXXXX/, "sio") + encoded
      when uri =~ /UBERON_/
        url = root.gsub(/XXXXX/, "uberon") + encoded
      when uri =~ /ORDO/
        url = root.gsub(/XXXXX/, "ordo") + encoded
      when uri =~ /CMO_/
        url = root.gsub(/XXXXX/, "cmo") + encoded
      end
      # warn "url is #{url} uri is #{uri}"
      if url.empty?
        warn "found no match for #{uri}"
        next
      end
      begin
        res = RestClient.get(url)
      rescue
        next
      end
      unless res
        warn "didn't resolve #{url}"
        next
      end
      j = JSON.parse(res.body)
      words << j["label"].to_s unless j["label"].to_s.empty?

      vpd = SPARQL.parse("
      PREFIX ejp: <http://purl.org/ejp-rd/vocabulary/>
      PREFIX dcat: <http://www.w3.org/ns/dcat#>
      PREFIX dc: <http://purl.org/dc/terms/>
  
      select ?kw WHERE
      { VALUES ?searchfields { dcat:keyword }
      ?s ?searchfields ?kw .
      }"
      )
      results = @graph.query(vpd)
      results.each do |res|
        words << res[:kw].to_s
      end
    end
    return words  
  end
end


class Wordcloud
  attr_accessor :words
  def initialize()
    if File.exists? "./cache/keywords.json"
      thaw
    else
      fdps = FDP::FDPSITES
      @words = []
      fdps.each do |fdp|
        site = FDP.new(address: fdp)
        @words << site.get_verbose_annotations
      end
      @words = @words.flatten
      warn "words\n\n#{@words}"
      freeze
    end
    @words
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
    begin
      kwf = File.open("./cache/keywords.json", "r")
      kw = kwf.read
      @words = JSON.parse(kw)
    rescue StandardError
      nil
    end
  end

  def freeze
    f = open("./cache/keywords.json", "w")
    f.puts @words.to_json
    f.close
  end

end