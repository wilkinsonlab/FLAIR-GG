# frozen_string_literal: false

require "openapi3_parser"
require "cgi"
require "rest-client"
require "json"

class ServiceCollection
  attr_accessor :vpgraph, :servicetype, :servicelabel, :allservices, :warnings, :escapedtype

  def initialize(vpgraph:, servicetype:)
    @vpgraph = vpgraph
    @servicetype = servicetype  # this is the URI of the service type
    @servicelabel = ontology_annotations uri: servicetype
    @escapedtype = CGI.escape(servicetype)
    @allservices = []
    @warnings = []

    collect_similar_services
  end

  def collect_similar_services
    warn "in collect similar services"
    vpd = SPARQL.parse("
    #{VP::NAMESPACES}
    SELECT DISTINCT ?contact ?title ?openapi ?endpoint WHERE
    {
      VALUES ?connection { #{VP::VPCONNECTION} }
      VALUES ?discoverable { #{VP::VPDISCOVERABLE} }

      ?s  ?connection ?discoverable ;
          a dcat:DataService ;
          dc:title ?title ;
          dcat:endpointURL ?endpoint ;
          dcat:endpointDescription ?openapi ;
          dc:type <#{servicetype}> .
      OPTIONAL{?s dcat:contactPoint ?c .
        ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
    }")
    results = vpgraph.query(vpd)
    results.each do |result|
      service = Service.new(contact: result[:contact], title: result[:title], openapi: result[:openapi],
                            endpoint: result[:endpoint])
      if service.successful
        @allservices << service  # only if there's a match!
      else
        # if not, no path in the openapi YAML matched the path in the DCAT
        @warnings << "The endpoint for #{service.contact} (#{service.endpoint}) in the DCAT did not match any endpoint in the OpenAPI YAML. It was therefore not returned"
      end
    end
  end

  def gather_common_parameters(method:)  # method is "get" or "post"
    commonparams = {}
    @allservices.each do |service|
      service.paths.each_key do |fullpath|
        params = service.retrieve_parameters(fullpath: fullpath, operation: method) 
        # params[param_name] = Openapi3Parser::Node::Parameter
        params.each_key do |paramname|
          warn "found #{paramname}"
          warn "already found #{paramname} - now overwriting" if commonparams[paramname]
          commonparams[paramname] = params[paramname]
        end
      end
    end
    commonparams
  end

  # "title": {
  #   "string": "Beacon2 v4  Individuals search of the DPP",
  # },
  # "openapi": {
  #   "value": "http://fairdata.services:10004/openapi.json",
  # },
  # "endpoint": {
  #   "value": "http://fairdata.services:10004/individuals",
  # },
  # "contact": {
  #   "value": "https://fairdata.systems",
  # },
  # "paths": {
  #   "http://fairdata.services:10004/individuals": {
  #     "get": null,
  #     "post": [
  #       [
  #         "summary",
  #         "Individuals Counts"
  #       ],
  #       [
  #         "operationId",
  #         "individuals_counts_individuals_post"
  #       ],
  def minimize_service_collection(commongetparams:, commonpostparams:)
    collection = {}
    commonget = {}
    commonpost = {}
    # "servicetype": "https://w3id.org/ejp-rd/vocabulary#VPBeacon2_individuals_4",
    # "servicelabel": "VPBeacon2_individuals_4",
    collection["servicetype"] = servicetype
    collection["servicelabel"] = servicelabel
    services = []
    allservices.each do |s|  # Service Object!
      paths = {}
      title = s.title
      openapi = s.openapi
      endpoint = s.endpoint
      contact = s.contact
      s.paths.each_key do |fullpath|
        paths[fullpath] = {}
        if s.paths[fullpath][:get]
          paths[fullpath]["get"] = "found"
        else 
          paths[fullpath]["get"] = nil
        end
        if s.paths[fullpath][:post]
          paths[fullpath]["post"] = "found"
        else
          paths[fullpath]["post"] = nil
        end
      end
      services << { "title" => title, "openapi" => openapi, "endpoint" => endpoint, "contact" => contact,
                    "paths" => paths }
    end
    collection["services"] = services

    commongetparams.each do |paramname, param|
      example = ""
      if param.schema.respond_to?("example") && param.schema.example =~ /\w/
        example = param.schema.example
      elsif param.schema.respond_to?("default") && param.schema.default =~ /\w/
        example = param.schema.default
      end
      commonget[paramname] = { "example" => example }
    end

    commonpostparams.each do |paramname, param|
      commonpost[paramname] = { "example" => "{\"YourJSON\": \"GoesHere\"}" }
    end
    
    collection["commongetparams"] = commonget
    collection["commonpostparams"] = commonpost

    collection  # this is the minimized collection
  end

end

class Service
  attr_accessor :contact, :title, :openapi, :endpoint, :apiobject, :base, :paths, :escapedendpoint, :successful

  def initialize(contact:, title:, openapi:, endpoint:)
    # NOTE - this object is initialitzed with the endpoint that is in the FDP Service record
    # therefore, when we retrieve the openAPI document, we scan it for ONLY that endpoint!
    @title = title # title of service from FDP
    @openapi = openapi  # URL of yaml
    @endpoint = endpoint  # URL
    @escapedendpoint = CGI.escape(endpoint)
    @contact = contact # contact of service from FDP
    @paths = {}   # in the end, this will have exactly one entry... so it probably shouldn't have been plural paths....
    @successful = false  # we are only successful if we eventually find the right path in the openAPI to match the FDP
    @apiobject = retrieve_endpoint(openapi: @openapi) # this will fill the @paths with a [:get] and [:post]
  end

  def retrieve_endpoint(openapi:)
    warn "retrieving #{openapi}"
    # this is just temporary until I get the docker image working
    begin
      resp = RestClient.get("https://converter.swagger.io/api/convert?url=#{openapi}").body
    rescue StandardError
      self.successful = false
      warn "couldn't convert #{openapi}"
      return nil
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
      return nil
    end

    # we are now scanning for the endpoint that was referenced in the FDP.
    # if we don't find it, we fail! (politely!)
    api.paths.each do |path, pathitem|
      warn "path #{path}"
      base = pathitem.servers.first.url
      fullpath = base + path
      warn "testing #{fullpath} against #{@endpoint}|"
      unless fullpath == @endpoint # compare it to the endpoint that was in the FDP
        warn "TEST FAILED"
        next
      end

      get = pathitem.get  #  Openapi3Parser::Node::Operation or nil
      post = pathitem.post  #  Openapi3Parser::Node::Operation or nil

      @paths[fullpath] = {} unless @paths[fullpath]  # initialize
      warn "\n\ninitializing with get: #{get}  and post #{post}\n"
      @paths[fullpath] = { get: get, post: post }
      self.successful = true
      break
    end
    api
  end

  def retrieve_parameters(fullpath:, operation:)
    # warn "retrieving fullpath #{fullpath} operation #{operation} from #{@paths.inspect}"
    params = {}
    get_or_post = @paths[fullpath][operation.to_sym]
    return params unless get_or_post  # if there's no match, return empty hash

    if operation.downcase == "post"
      json_request_body = get_json_request(request_body: get_or_post.request_body)
      params["_request_body"] = json_request_body
    end

    get_or_post.parameters.each do |param|
      warn "loading #{param.name}"
      params[param.name] = param  # responds to "in", "name", "description", "schema.example", "schema.type"
    end
    # warn "\n\nFINAL #{params.inspect}\n\n"
    params
  end

  def get_json_request(request_body:)

      # CHECK POST!
      # pathitem.post.request_body.content
      # ["application/json", Openapi3Parser::Node::MediaType(#/paths/~1individuals/post/requestBody/content/application~1json)]
      # This call generates a list of lists, with the first element being the media type

      # pathitem.post.request_body.content.first[1].schema.example
      # the [1] here is electing the node, which then has the schema and the example
      request_body.content.each do |mediatype, node|
        next unless mediatype == "application/json"
        return node
      end
  end

  def self.execute_post(endpoint:, body:, auth_key: nil)
    warn "POSTING: #{body}"
    # example data for beacon {"meta":{"apiVersion":"v0.2"},"query":{"filters":[{"id":["ordo:Orphanet_730"]}]}}
    begin
      result = RestClient::Request.execute(
        method: :post,
        url: endpoint,
        payload: body["_request_body"],
        headers: {
          content_type: :json,
          accept: :json,
          # "auth-key" => ""
        }
      )
    rescue  => e
      warn "couldn't execute POST service at #{endpoint}\n #{e.inspect}"
      result = nil
    end
    result
  end

  def self.execute_get(endpoint:, params:, auth_key: nil)
    begin
      result = RestClient::Request.execute(
        method: :get,
        url: endpoint,
        headers: {
          params: params,
          # "auth-key" => ""
        }
      )
    rescue  => e
      warn "couldn't execute GET service at #{endpoint}\n #{e.inspect}"
      result = nil
    end
    result
  end
end
