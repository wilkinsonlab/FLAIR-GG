require "json"
require "linkeddata"

QUERY1 = "select ?title where {|||SUBJECT||| ?p ?title . FILTER(CONTAINS(lcase(str(?p)), 'title'))}"
QUERY2 = "select ?title where {|||SUBJECT||| ?p1 ?o . ?o ?p2 ?title .
          FILTER(CONTAINS(lcase(str(?p1)), 'name')) .
          FILTER(CONTAINS(lcase(str(?p2)), 'textvalue'))}"
QUERY3 = "select ?title where {|||SUBJECT||| <http://www.w3.org/2000/01/rdf-schema#label> ?title }"
QUERY4 = "select ?title where {|||SUBJECT||| ?p1 ?title .
          FILTER(CONTAINS(lcase(str(?p1)), 'name')) }"
QUERY5 = "select ?title where {|||SUBJECT||| <http://www.w3.org/2000/01/rdf-schema#label> ?title .}"


TYPEHASH = {
  "text/turtle" => :turtle,
  "application/ld+json" => :jsonld,
  "application/rdf+xml" => :rdfxml,
  "text/html" => :rdfa
}

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
  if match = body.match(%r{<script\s+type="application/ld\+json">((.|\n|\r)*?)</script})
    jsonld = match[1]
    jsonld = jsonld.encode(Encoding.find("UTF-8"), invalid: :replace, undef: :replace, replace: "")
    data = StringIO.new(jsonld.encode("UTF-8"))
    RDF::Reader.for(:jsonld).new(data) do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
  end
  graph
end

def resolve_url_to_json(url:, accept: "application/json")
  graph = RDF::Graph.new
  type = TYPEHASH[accept] # e.g. :turtle  for the RDF reader

  begin
    r = RestClient::Request.execute(
      method: :get,
      url: url,
      headers: { accept: accept }
    )
  rescue StandardError
    warn "#{url} didn't resolve when trying for #{accept} #{r}"
    r = RestClient::Request.execute(
      method: :get,
      url: url,
      headers: { accept: accept }
    )
  end

  body = r.body
  body = body.encode(Encoding.find("UTF-8"), invalid: :replace, undef: :replace, replace: "")
  JSON.parse(body)
end

def resolve_url_to_rdf(url:, accept: "text/turtle")
  graph = RDF::Graph.new
  type = TYPEHASH[accept] # e.g. :turtle  for the RDF reader

  warn "retrieving type: #{type}"
  begin
    r = RestClient::Request.execute(
      method: :get,
      url: url,
      headers: { accept: accept }
    )
  rescue StandardError
    warn "#{url} didn't resolve when trying for #{accept} #{r}"
    return graph
  end

  body = r.body
  # warn "RETURNED BODY:  #{body}\n\n"
  body = body.encode(Encoding.find("UTF-8"), invalid: :replace, undef: :replace, replace: "")
  data = StringIO.new(body.encode("UTF-8"))
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

def refresh_cache
  f = open("./cache/REFRESHING", "w") # multiple browser calls are a problem!
  f.puts "REFRESHING"
  f.close
  FDPConfig.new  # initialize
  fdps = FDPConfig::FDPSITES
  fdps.each do |fdp_address|
    warn "working with #{fdp_address}"
    fdp = FDP.new(address: fdp_address, refresh: true)
    hash = fdp.find_discoverables
    @discoverables.merge!(hash)
  end
  FileUtils.rm_f("./cache/REFRESHING")
end

def get_resources
  discoverables = {}
  FDPConfig.new  # initialize
  fdps = FDPConfig::FDPSITES
  fdps.each do |fdp_address|
    fdp = FDP.new(address: fdp_address, refresh: false)
    hash = fdp.find_discoverables
    discoverables.merge!(hash)
  end
  discoverables
end

def keyword_search_shell(keyword:)
  warn "in keyword search now\n\n\n"
  discoverables = {}
  FDPConfig.new  # initialize
  fdps = FDPConfig::FDPSITES
  fdps.each do |fdp_address|
    warn "searching #{fdp_address}"
    fdp = FDP.new(address: fdp_address, refresh: false)
    warn "starting keyword search #{keyword}"
    hash = fdp.keyword_search(keyword: keyword)
    discoverables.merge!(hash)
  end
  discoverables
end

def ontology_search_shell(term:)
  discoverables = {}
  FDPConfig.new # initialize
  fdps = FDPConfig::FDPSITES
  fdps.each do |fdp_address|
    fdp = FDP.new(address: fdp_address, refresh: false)
    hash = fdp.ontology_search(uri: term)
    discoverables.merge!(hash)
  end
  discoverables
end
