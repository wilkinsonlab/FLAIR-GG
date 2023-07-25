require "linkeddata"
require "digest"
require "restclient"
# frozen_string_literal: false
class FDP
  attr_accessor :graph, :address, :called

  def initialize(address:, refresh:)
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
    discoverables = Hash.new
    vpd = SPARQL.parse("SELECT ?s ?t ?title WHERE 
    { ?s <http://purl.org/ejp-rd/vocabulary/vpConnection> <http://purl.org/ejp-rd/vocabulary/VPDiscoverable> ;
    <http://purl.org/dc/terms/title> ?title ;
    a ?t }")
    theme = SPARQL.parse("SELECT ?s ?t  ?title WHERE 
    { ?s <http://www.w3.org/ns/dcat#theme> <http://purl.org/ejp-rd/vocabulary/VPDiscoverable> ;
    <http://purl.org/dc/terms/title> ?title ;
    a ?t }")
    theme2 = SPARQL.parse("SELECT ?s ?t  ?title WHERE 
    { ?s <http://www.w3.org/ns/dcat#themeTaxonomy> <http://purl.org/ejp-rd/vocabulary/VPDiscoverable> ;
    <http://purl.org/dc/terms/title> ?title ;
    a ?t }")
    @graph.query(vpd) do |result|
      next if result[:t].to_s =~ /\#Resource/
      discoverables[result[:s].to_s] = {title: result[:title].to_s, type: result[:t].to_s}
    end
    @graph.query(theme) do |result|
      next if result[:t].to_s =~ /\#Resource/
      discoverables[result[:s].to_s] = {title: result[:title].to_s, type: result[:t].to_s}
    end
    @graph.query(theme2) do |result|
      next if result[:t].to_s =~ /\#Resource/
      discoverables[result[:s].to_s] = {title: result[:title].to_s, type: result[:t].to_s}
    end
    warn discoverables
    discoverables = discoverables.sort_by {|k,v| v[:type]}.to_h
    discoverables
  end

  def grab_contains; end
end
