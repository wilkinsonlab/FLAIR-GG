require_relative "ontologyservers/bioregistry"
require_relative  "ontologyservers/identifiers"
require_relative  "ontologyservers/ebi_ontology"
require_relative  "ontologyservers/ebi_ontology_v3"
require_relative  "ontologyservers/ontobee"
require_relative  "ontologyservers/etsi"
require_relative  "ontologyservers/bio2rdf"
require_relative  "ontologyservers/ncbo"
require_relative  "ontologyservers/schema"

require_relative  "wordcloud"
require_relative  "cache"
require_relative  "metadata_functions"


class FDP
  attr_accessor :graph, :address, :called

  def initialize(address:)
    @graph = RDF::Graph.new
    @address = address  # address of this FDP
    @called = []  # has this address already been called?  List of known
    warn "refreshing"
    load(address: address)  # THIS IS A RECURSIVE FUNCTION THAT FOLLOWS ldp:contains 
    freezeme
  end

  def self.load_from_cache(vp:, marshalled:)
    begin
      warn "thawing file #{marshalled}"
      fdpstring = File.read(marshalled)
      fdp = Marshal.load(fdpstring)
    rescue StandardError
      nil
    end
    fdp
  end

  def load(address:)
    return if called.include? address

    called << address
    address = address.gsub(%r{/$}, "")
    address += "?format=ttl"
    warn "getting #{address}"
    begin
      r = RestClient.get(address)
    rescue e
      warn "#{address} didn't resolve"
    end

    parse(message: r.body) if r&.body
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
      end
    end
  end

  def freezeme
    address = Digest::SHA256.hexdigest @address
    f = File.open("./cache/#{address}.marsh", "w")
    str = Marshal.dump(self).force_encoding("ASCII-8BIT")
    f.puts str
    f.close
  end



end
