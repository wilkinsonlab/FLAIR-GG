require 'json'
require 'linkeddata'
require_relative  './metadata_functions.rb'

class BioRegistry
  attr_accessor :uri
  attr_accessor :synonym_urls

  def initialize(uri:)
    @uri = uri
    @synonym_urls = []
    term = uri.match(%r{.*/(\S+?)$})[1] # edam:data_1153
    bioreg = "https://bioregistry.io/api/reference/#{term}"
    warn "BIOREG #{bioreg}"

    warn "This isn't an bioregistry.org URI, don't expect this to work!" unless @uri =~ /\/bioregistry\.io\//
    begin
      response = RestClient.get(bioreg, 
      #headers: {accept: "text/turtle, application/ld+json, application/rdf+xml"}
      )
    rescue
      warn "#{uri} didn't resolve #{response}"
    end
    #return nil unless response
    json = JSON.parse(response.body)
    @synonym_urls = json['providers'].map {|providerid, providerurl| providerurl unless ["bioregistry", "miriam"].include? providerid}
    @synonym_urls.compact!
    @synonym_urls

  end

end
