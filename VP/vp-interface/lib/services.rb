require "openapi3_parser"

class ServiceCollection
  attr_accessor :vpgraph, :servicetype, :allservices, :warnings

  def initialize(vpgraph:, servicetype:)
    @vpgraph = vpgraph
    @servicetype = servicetype
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
    }"
    )
    results = vpgraph.query(vpd)
    results.each do |result|
      service = Service.new(contact: result[:contact], title: result[:title], openapi: result[:openapi], endpoint: result[:endpoint])
      @allservices << service
    end
  end

  def gather_common_parameters
    commonparams = {}
    @allservices.each do |service|
      service.paths.each_key do |fullpath|
        params = service.retrieve_parameters(fullpath: fullpath, operation: "get")  # only get for the moment
        params.each_key do |paramname|
          warn "found #{paramname}"
          if commonparams[paramname]
            warn "already found #{paramname} - now overwriting"
            @warnings << "overwriting with #{fullpath} - this might be good news!?"
          end
          commonparams[paramname] = params[paramname]
        end
      end
    end
    commonparams
  end
end

class Service
  attr_accessor :contact, :title, :openapi, :endpoint, :apiobject, :base, :paths

  def initialize(contact:, title:, openapi:, endpoint:)
    @title = title
    @openapi = openapi
    @endpoint = endpoint
    @contact = contact
    @paths = {}
    @apiobject = retrieve_endpoint(openapi: @openapi)
  end

  def retrieve_endpoint(openapi:)
    warn "retrieving #{openapi}"
    api = Openapi3Parser.load_url(openapi)
    #@base = api["servers"].first[a.paths.keys"url"]
    api.paths.each do |path, pathitem|
      warn "path #{path}"
      base = pathitem.servers.first.url
      get = pathitem.get
      post = pathitem.post
      fullpath = base + path
      @paths[fullpath] = {} unless @paths[fullpath]
      @paths[fullpath] = { get: get, post: post }
    end
  end

  def retrieve_parameters(fullpath:, operation:)
    abort if operation == "post"
    warn "retrieving fullpath #{fullpath} operation #{operation} from #{@paths.inspect}"
    params = {}
    service = @paths[fullpath][operation.to_sym]
    # leave post for later
    # params["_request_body"] = service.request_body
    service.parameters.each do |param|
      warn "loading #{param.name} #{param}"
      params[param.name] = param  # responds to "in", "name", "description", "schema.example", "schema.type"
    end
    params
  end
end

