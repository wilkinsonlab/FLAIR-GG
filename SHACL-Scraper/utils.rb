require "rest-client"
require "linkeddata"
require "json"
require "rdf/raptor"

def get_fdps(index: "http://138.4.139.18:9090/index/entries?page=0&size=1000&sort=string")
  r = RestClient::Request.execute(
    method: :get,
    url: index,
    headers: { accept: "application/json" }
  )
  body = r.body
  warn body
  body = body.encode(Encoding.find("UTF-8"), invalid: :replace, undef: :replace, replace: "")
  j = JSON.parse(body)

  fdps = j["content"].map { |fdp| fdp["clientUrl"] if fdp["state"] == "ACTIVE" }
  fdps.compact
  fdps = [fdps] unless fdps.is_a? Array
  fdps
end

# curl -X POST -H "Accept: application/json" \
#     -H "Content-Type: application/json" \
#     -d '{ "email": "user@example.com", "password": "secret" }' \
#     https://fdp.example.com/tokens
def get_token(fdp:)
  fdp.gsub(%r{/$}, "") # strip tailing slash
  fdp += "/tokens" unless fdp.match(/tokens$/)
  warn "FDP:  #{fdp} pass #{ARGV[0]}"
  r = fetch(url: fdp,
            method: :post,
            data: { email: "mark.wilkinson@upm.es", password: ARGV[0] },
            headers: { accept: "application/json",
                       content_type: "application/json" })
  # r = RestClient::Request.execute(
  #   method: :post,
  #   url: fdp,
  #   headers: { accept: "application/json", "email": "mark.wilkinson@upm.es", "password": ARGV[0] }
  # )
  JSON.parse(r.body)["token"]
end

def get_catalogs(fdp:, token:)
  #  curl -L -X GET http://localhost:7070/meta -H "accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzOWUwZmE0Ny0wYmZkLTRhNTYtYjA5ZS0xMjU2ODVlNmE1NDUiLCJpYXQiOjE2OTkwMjA5NDQsImV4cCI6MTcwMDIzMDU0NH0.6adtdWMlQWUz8R506tDlJsRHB3fIlOS8tQIjHs-Jeom_8oyv8ionK0yS81OfJT6CpVz2mrpHjujcFnizbmuQBQ"
  fdp.gsub(%r{/$}, "") # strip tailing slash
  fdp += "/meta" unless fdp.match(/meta$/)
  r = RestClient::Request.execute(
    method: :get,
    url: fdp,
    headers: { accept: "application/json", authorization: "Bearer #{token}" }
  )
  cats = JSON.parse(r.body)["state"]["children"].map { |c| c[0] if c[1] == "PUBLISHED" }
  cats.compact

  # {"member":
  #   {},
  # "state":
  #   {"current":"PUBLISHED",
  #    "children":
  #     {"https://w3id.org/bgv-fdp/catalog/3e699f66-6b8a-4c6a-9d06-d8685718cc33":"PUBLISHED"}
  #   },
  # "path":
  #   {"https://w3id.org/bgv-fdp":
  #     {"resourceDefinitionUuid":"77aaad6a-0136-4c6e-88b9-07ffccd0ee4c",
  #     "title":"César Gómez Campo Banco de Germoplasma Vegetal de la UPM ",
  #     "parent":null}
  #   }
  # }
end

def get_datasets(cat:, token:)
  #  curl -L -X GET http://localhost:7070/meta -H "accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzOWUwZmE0Ny0wYmZkLTRhNTYtYjA5ZS0xMjU2ODVlNmE1NDUiLCJpYXQiOjE2OTkwMjA5NDQsImV4cCI6MTcwMDIzMDU0NH0.6adtdWMlQWUz8R506tDlJsRHB3fIlOS8tQIjHs-Jeom_8oyv8ionK0yS81OfJT6CpVz2mrpHjujcFnizbmuQBQ"
  cat.gsub(%r{/$}, "") # strip tailing slash
  cat += "/meta" unless cat.match(/meta$/)
  r = RestClient::Request.execute(
    method: :get,
    url: cat,
    headers: { accept: "application/json", authorization: "Bearer #{token}" }
  )
  dsets = JSON.parse(r.body)["state"]["children"].map { |c| c[0] if c[1] == "PUBLISHED" }
  dsets.compact
end

def get_distributions(dset:, token:)
  #  curl -L -X GET http://localhost:7070/meta -H "accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzOWUwZmE0Ny0wYmZkLTRhNTYtYjA5ZS0xMjU2ODVlNmE1NDUiLCJpYXQiOjE2OTkwMjA5NDQsImV4cCI6MTcwMDIzMDU0NH0.6adtdWMlQWUz8R506tDlJsRHB3fIlOS8tQIjHs-Jeom_8oyv8ionK0yS81OfJT6CpVz2mrpHjujcFnizbmuQBQ"
  dset.gsub(%r{/$}, "") # strip tailing slash
  dset += "/meta" unless dset.match(/meta$/)
  r = RestClient::Request.execute(
    method: :get,
    url: dset,
    headers: { accept: "application/json", authorization: "Bearer #{token}" }
  )
  dists = JSON.parse(r.body)["state"]["children"].map { |c| c[0] if c[1] == "PUBLISHED" }
  dists.compact
end

def get_data_services(dist:, token:)
  #  curl -L -X GET http://localhost:7070/meta -H "accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzOWUwZmE0Ny0wYmZkLTRhNTYtYjA5ZS0xMjU2ODVlNmE1NDUiLCJpYXQiOjE2OTkwMjA5NDQsImV4cCI6MTcwMDIzMDU0NH0.6adtdWMlQWUz8R506tDlJsRHB3fIlOS8tQIjHs-Jeom_8oyv8ionK0yS81OfJT6CpVz2mrpHjujcFnizbmuQBQ"
  dist.gsub(%r{/$}, "") # strip tailing slash
  dist += "/meta" unless dset.match(/meta$/)
  r = RestClient::Request.execute(
    method: :get,
    url: dist,
    headers: { accept: "application/json", authorization: "Bearer #{token}" }
  )
  servs = JSON.parse(r.body)["state"]["children"].map { |c| c[0] if c[1] == "PUBLISHED" }
  servs.compact
end

def get_sparql_endpoints(serv:)
  results = Hash.new
  graph = RDF::Graph.load("#{serv}.ttl")
  query = SPARQL.parse("SELECT ?dset ?endpoint WHERE { 
    ?s <http://www.w3.org/ns/dcat#endpointURL> ?endpoint .
    ?s <http://www.w3.org/ns/dcat#servesDataset> ?dset}")
  query.execute(queryable) do |result|
    dset = result[:dset]
    endpoint = result[:endpoint]
    results[dset] = endpoint
  end
  results
end

def write_to_repo(shacl:, catalog:)
  shacl = RestClient.get(shacl)
  response = RestClient.execute(
    method: :post,
    # url: "http://138.4.139.18:8890/DAV/home/LDP/ShaclIndex/",
    url: "http://localhost:8890/DAV/home/LDP/ShaclIndex/",
    headers: { content_type: "text/turtle", accept: "text/turtle" },
    payload: "@prefix ldp:	<http://www.w3.org/ns/ldp#> . <>    rdf:type   ldp:Container ."
  )
  newcontainer = response.headers[:location]
  url = newcontainer.gsub(/http:\/\//, "http://ldp:ldp@")
  _response = RestClient.execute(
    method: :put,
    url: url,
    headers: { content_type: "text/turtle", accept: "text/turtle", slug: "shacl"},
    payload: shacl
  )
  _response = RestClient.execute(
    method: :post,
    url: url,
    headers: { content_type: "text/plain", accept: "text/turtle", slug: "url"},
    payload: catalog
  )
end

def fetch(url:, method:, headers:, data:)
  begin
    warn "trying #{url}"
    r = RestClient::Request.execute(
      method: method,
      url: url,
      headers: headers,
      payload: JSON.generate(data)
    )
  rescue RestClient::ExceptionWithResponse => e
    warn "rescuing!"
    if [307].include? e.response.code
      url = e.response.headers[:location]
      retry
    end
    puts e.response
  end
  r
end
