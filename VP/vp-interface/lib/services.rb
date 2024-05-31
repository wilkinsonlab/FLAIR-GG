# frozen_string_literal: false

require "openapi3_parser"
require "cgi"

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
      service = Service.new(contact: result[:contact], title: result[:title], openapi: result[:openapi], endpoint: result[:endpoint])
      if service.successful
        @allservices << service  # only if there's a match!
      else
        # if not, no path in the openapi YAML matched the path in the DCAT
        @warnings << "The endpoint for #{service.contact} (#{service.endpoint}) in the DCAT did not match any endpoint in the OpenAPI YAML. It was therefore not returned"
      end
    end
  end

  def gather_common_parameters(method:)
    commonparams = {}
    @allservices.each do |service|
      service.paths.each_key do |fullpath|
        params = service.retrieve_parameters(fullpath: fullpath, operation: method)  # only get for the moment
        params.each_key do |paramname|
          warn "found #{paramname}"
          if commonparams[paramname]
            warn "already found #{paramname} - now overwriting"
            # @warnings << "overwriting with #{fullpath} - this might be good news!?"
          end
          commonparams[paramname] = params[paramname]
        end
      end
    end
    commonparams
  end
end

class Service
  attr_accessor :contact, :title, :openapi, :endpoint, :apiobject, :base, :paths, :escapedendpoint, :successful

  def initialize(contact:, title:, openapi:, endpoint:)
    @title = title
    @openapi = openapi
    @endpoint = endpoint
    #    @escapedendpoint = ERB::Util.url_encode(endpoint)
    @escapedendpoint = CGI.escape(endpoint)
    @contact = contact
    @paths = {}
    @successful = false
    @apiobject = retrieve_endpoint(openapi: @openapi) # this will fill the @paths with a [:get] and [:post]
  end

  def retrieve_endpoint(openapi:)
    warn "retrieving #{openapi}"
    api = Openapi3Parser.load_url(openapi)
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
    api
  end

  def retrieve_parameters(fullpath:, operation:)
    warn "retrieving fullpath #{fullpath} operation #{operation} from #{@paths.inspect}"
    params = {}
    service = @paths[fullpath][operation.to_sym]
    return params unless service  # if there's no match, return nothing

    warn "PATHS:  #{@paths.inspect}\nFULLPATH: #{fullpath}\nOPERATION: #{operation}\n"
    # leave post for later
    if operation == "post"
      params["_request_body"] = service.request_body
    end
    warn "\nparameters for #{fullpath} are #{service.parameters}\n"
    service.parameters.each do |param|
      warn "loading #{param.name} #{param}"
      params[param.name] = param  # responds to "in", "name", "description", "schema.example", "schema.type"
    end
    warn "\n\nFINAL #{params.inspect}\n\n"

    params
  end
end
