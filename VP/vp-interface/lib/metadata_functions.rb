require "json"
require "linkeddata"

QUERY1 = "select ?title where {?s ?p ?title . FILTER(CONTAINS(lcase(str(?p)), 'title'))}"
QUERY2 = "select ?title where {?s ?p1 ?o . ?o ?p2 ?title .
          FILTER(CONTAINS(lcase(str(?p1)), 'name')) .
          FILTER(CONTAINS(lcase(str(?p2)), 'textvalue'))}"

def resolve_url_to_jsonld(url:)
  graph = RDF::Graph.new
  begin
    r = RestClient.get(url)
  # headers: {accept: "text/turtle, application/ld+json, application/rdf+xml"}
  rescue StandardError
    warn "#{url} didn't resolve to HTML #{r}"
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

def resolve_url_to_embedded_metadata(url:)
  begin
    r = RestClient.get(url,
                       headers: { accept: "text/turtle, application/ld+json, application/rdf+xml" })
  rescue StandardError
    warn "#{url} didn't resolve using content type headers #{r}"
    return nil
  end
  # formattype = RDF::Format.for({:sample => r.body[0..3000]})
  graph = RDF::Graph.new
  b = r.body
  b = b.encode(Encoding.find("UTF-8"), invalid: :replace, undef: :replace, replace: "")
  data = StringIO.new(b.encode("UTF-8"))
  RDF::Reader.for(:rdfa).new(data) do |reader|
    reader.each_statement do |statement|
      graph << statement
    end
  end
  graph
end

def lookup_title(synonym_urls:)
  title = nil
  synonym_urls.each do |url|
    if (graph = resolve_url_to_jsonld(url: url)) # for orphanet, the more accurate title is in the jsonld
      title = find_title_in_graph(graph: graph)
    end

    unless title
      graph = resolve_url_to_embedded_metadata(url: url) # the rdfa contains a title, but it is prefixed with "Orphanet"
      title = find_title_in_graph(graph: graph)
    end
  end
  title
end

def find_title_in_graph(graph:)
  title = nil
  [QUERY1, QUERY2].each do |query|
    query = SPARQL.parse(query)
    graph.query(query) do |result|
      warn "found title #{result[:title]}"
      title = result[:title] if result[:title]
    end
  end
  title.to_s
end
