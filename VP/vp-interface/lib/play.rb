require "openapi3_parser"
require "cgi"
require "rest-client"
require "json"

# openapi = "https://wilkinsonlab.github.io/FLAIR-GG/VP/interfaces/germplasm-sparql.yaml"
# openapi = "https://fairdata.services/api-local/swagger"
openapi = "http://fairdata.services:10004/openapi.json"
warn "retrieving #{openapi}"
# this is just temporary until I get the docker image working
begin
  resp = RestClient.get("https://converter.swagger.io/api/convert?url=#{openapi}").body
rescue StandardError
  self.successful = false
  warn "couldn't convert #{openapi}"
  # return nil
end

warn resp
# converter makes a mess of the URLs together with the grlc output... munge it
j = JSON.parse(resp)
j["servers"].each do |s|
  s["url"].gsub!(%r{/$}, "")
  s["url"].gsub!(%r{^//}, "https://")
end
resp = j.to_json   # back to json for the openapi3
begin
  api = Openapi3Parser.load(resp)
rescue StandardError
  self.successful = false
  warn "couldn't parse openapi document at #{openapi}"
  # return nil
end
# api = Openapi3Parser.load_url(openapi)
api.paths.each do |path, pathitem|
  warn "path #{path}"
  base = pathitem.servers.first.url
  get = pathitem.get  #  Openapi3Parser::Node::Operation or nil
  post = pathitem.post  #  Openapi3Parser::Node::Operation or nil
  fullpath = base + path
  warn "testing #{fullpath} against #{@endpoint}|"
  unless fullpath == @endpoint # this seems a bit dangerous, but it should be the same as what is in the DCAT record...
    warn "TEST FAILED"
    next
  end

  @paths[fullpath] = {} unless @paths[fullpath]  # initialize
  warn "\n\ninitializing with get: #{get}  and post #{post}\n"
  @paths[fullpath] = { get: get, post: post }
  self.successful = true
  break
end
