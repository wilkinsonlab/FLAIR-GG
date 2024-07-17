# frozen_string_literal: false

require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"
require "fileutils"
require "require_all"

require_rel 'ontologyservers'
require_rel 'serviceoutput_processers'
require_rel 'discoverable'


class VP
  attr_accessor :networkgraph, :vpconfig, :fdps, :aboutme

  NAMESPACES = "PREFIX ejpold: <http://purl.org/ejp-rd/vocabulary/>
  PREFIX ejpnew: <https://w3id.org/ejp-rd/vocabulary#>
  PREFIX dcat: <http://www.w3.org/ns/dcat#>
  PREFIX dc: <http://purl.org/dc/terms/>
  ".freeze
  # VPCONNECTION = "ejpold:vpConnection ejpnew:vpConnection dcat:theme dcat:themeTaxonomy".freeze
  # VPDISCOVERABLE = "ejpold:VPDiscoverable ejpnew:VPDiscoverable".freeze
  # VPANNOTATION = "dcat:theme".freeze
  VPCONNECTION = "ejpnew:vpConnection".freeze
  VPDISCOVERABLE = "ejpnew:VPDiscoverable".freeze
  VPANNOTATION = "dcat:theme".freeze

  @@thisvp = ""

  def initialize(config: vpconfig)
    @vpconfig = config # my configuration
    @networkgraph = RDF::Graph.new # the full network of FDP triples
    @fdps = []  # the FDPs that I know
    @aboutme = []  # the list of keywords for the word cloud
    load_fdps_from_cache
    @@thisvp = self
  end

  def self.current_vp
    @@thisvp
  end

  def load_fdps_from_cache()
    Dir["./cache/*.marsh"].select { |f| !File.directory? File.join("./cache/", f) }.each do |marsh|
      fdp = FDP.load_from_cache(vp: self, marshalled: marsh)
      add_fdp(fdp: fdp)
    end
  end

  def add_fdp(fdp: )
    warn "fdp graph size #{fdp.graph.size}"
    @networkgraph << fdp.graph.statements
    warn "network graph size #{@networkgraph.size}"
    @fdps << fdp
  end

  def self.restart
    f = open("./cache/REFRESHING", "w") # multiple browser calls are a problem!
    f.puts "REFRESHING"
    f.close

    fdpsites = VPConfig::FDPSITES   # current sites
    fdpsites.each do |fdp_address|   # one for every active FDP site
      warn "deleting #{fdp_address}"
      hexaddress = Digest::SHA256.hexdigest fdp_address
      FileUtils.rm_f("./cache/#{hexaddress}.marsh")  # clear existing cache
    end

    vp = VP.new(config: VPConfig.new)  # refresh from index

    fdpsites = VPConfig::FDPSITES   # new set of sites
    fdpsites.each do |fdp_address|   # one for every active FDP site
      warn "working with #{fdp_address}"
      fdp = FDP.new(address: fdp_address)
      fdp.freezeme
      vp.add_fdp(fdp: fdp)
    end
    FileUtils.rm_f("./cache/REFRESHING")
    @@thisvp = vp  # set current VP to class variable
  end

  def get_resources
    discoverables = find_discoverables  # things that have been flagged as "VPDiscoverable"
    discoverables
  end
  
  def find_discoverables
    @graph = self.networkgraph

    vpd = SPARQL.parse("

      #{NAMESPACES}
      SELECT DISTINCT ?s ?t ?title ?contact ?servicetype WHERE
      { 
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }

        ?s  ?connection ?discoverable ;
            dc:title ?title ;
            a ?t .

        OPTIONAL{?s dcat:contactPoint ?c .
                 ?c <http://www.w3.org/2006/vcard/ns#url> ?contact }.
        OPTIONAL{?s dc:type ?servicetype }.

      }
      ")
    discoverables = build_from_results(results: @graph.query(vpd))
    warn discoverables
    discoverables
  end

  def keyword_search_shell(keyword:)
    warn "in keyword search now\n\n\n"
    discoverables = keyword_search(keyword: keyword)
    discoverables
  end

  def ontology_search_shell(term:)
    warn "in ontology search shell"
    discoverables = ontology_search(uri: term)
    discoverables
  end

  def keyword_search(keyword: "")
    @graph = self.networkgraph
    keyword = keyword.downcase
    vpd = SPARQL.parse("
    #{NAMESPACES}

    SELECT DISTINCT ?s ?t ?title ?contact WHERE
    { 
      VALUES ?connection { #{VPCONNECTION} }
      VALUES ?discoverable { #{VPDISCOVERABLE} }
      ?s  ?connection ?discoverable ;
          dc:title ?title ;
          a ?t .
      OPTIONAL{?s dcat:contactPoint ?c .
               ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
          {
              VALUES ?searchfields { dc:title dc:description dc:keyword }
              ?s ?searchfields ?kw 
              FILTER(CONTAINS(lcase(?kw), '#{keyword}'))
          }
    }"
    )
    warn "keyword search query #{vpd.to_sparql}"
    warn "graph is #{@graph.size}"
    warn "results of query #{@graph.query(vpd)}"
    discoverables = build_from_results(results: @graph.query(vpd))
    warn discoverables
    discoverables
  end

  def ontology_search(uri: "")
    @graph = self.networkgraph
    warn "in ontology search"
    warn "parse start"
    vpd = SPARQL.parse("

    #{NAMESPACES}

    SELECT DISTINCT ?s ?t ?title ?contact WHERE
    {
      VALUES ?connection { #{VPCONNECTION} }
      VALUES ?discoverable { #{VPDISCOVERABLE} }

      ?s  ?connection ?discoverable ;
          dc:title ?title ;
          a ?t .
      OPTIONAL{?s dcat:contactPoint ?c .
               ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
          {
              ?s dcat:theme ?theme .
              FILTER(CONTAINS(str(?theme), '#{uri}'))
          }
    }"
    )
    warn "parse end"
    warn "query start"
    results = @graph.query(vpd)
    warn "query end"

    discoverables = build_from_results(results: results)
    warn discoverables
    discoverables
  end

  def verbose_annotations
    @graph = self.networkgraph
    words = []

    # TODO  This does not respect vpdiscoverable...
    vpd = SPARQL.parse("
    #{NAMESPACES}
    SELECT DISTINCT ?annot WHERE
    { VALUES ?annotation { dcat:theme dcat:themeTaxonomy }
      ?s  ?annotation ?annot .
      }")
    results = @graph.query(vpd)
    results.each do |res|
      uri = res[:annot].to_s
      word = ontology_annotations(uri: uri)
      next unless word
      next unless !word.empty?
      words << word.capitalize
    end
    # end of taxonomy parser

    warn "\n\nSWITCH TO KEYWORDS\n\n"
    vpd = SPARQL.parse("
    #{NAMESPACES}
    select DISTINCT ?kw WHERE
    { VALUES ?searchfields { dc:keyword }
    ?s ?searchfields ?kw .
    }")
    results = @graph.query(vpd)
    results.each do |res|
      next unless !res[:kw].to_s.empty?
      words << res[:kw].to_s.capitalize
    end
    words.compact!
    warn "PROVIDER WORDS:  #{words}"
    words
  end

  def collect_data_services
    if File.exist?("./cache/servicetypes.json")
      services = thaw_servicetypes
    else
      graph = self.networkgraph
      warn "in collect data services"
      vpd = SPARQL.parse("

      #{NAMESPACES}

      SELECT DISTINCT ?type WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }

        ?s  ?connection ?discoverable ;
            a dcat:DataService .
            {
                ?s dc:type ?type .
            }
      }"
      )
      results = graph.query(vpd)
      prehash = {}
      results.each do |r|
        type = r[:type].to_s;
        next if prehash[type]  # already known

        warn "subject type #{type}"
        kw = ontology_annotations(uri: type)
        prehash[type] = kw
      end
      services = prehash.map {|k,v| [k,v] } # remove trailing space and turn into array
      freeze_servicetypes(types: services)
    end
    services
  end

  def retrieve_sevices(termuri:)  #  the URI of the service type
    # hand off to services_functions
    servicecollection = ServiceCollection.new(vpgraph: self.networkgraph, servicetype: termuri)
    commongetparams = servicecollection.gather_common_parameters(method: "get")
    commonpostparams = servicecollection.gather_common_parameters(method: "post")
    [servicecollection, commongetparams, commonpostparams]
  end

  def execute_data_services(params:)
    endpoints = params.delete("endpoint") # returns an array of endpoints from the checkboxes
    results = {}
    servicelabel = params["servicelabel"].downcase
    endpoints.each do |ep|
      endpoint = CGI.unescape(ep)
      if params["_request_body"]
        warn "POSTING: #{params["_request_body"]}"
        # example data for beacon {"meta":{"apiVersion":"v0.2"},"query":{"filters":[{"id":["ordo:Orphanet_730"]}]}}
        result = RestClient.post(endpoint, params["_request_body"], {content_type: :json, accept: :json} )
      else
        result = RestClient.get(endpoint, {params: params})
      end
      warn result.inspect
      results[endpoint] = result.body
    end
    location = process_and_upload_output(results: results) # in serviceoutput_processors/general.rb
    [location, servicelabel, results]
  end

  def match_type_to_icon(type:)

    t = type.match(%r{[\#/](\w+?)$})[1].downcase.to_sym  # anchor to end to capture last / or #
    warn "matching #{t}\n\n"
    hash = {
      biobank: "biobank.svg",
      catalog: "catalog.svg",
      dataservice: "dataservice.svg",
      distribution: "distribution.svg",
      dataset: "dataset.svg",
      patientregistry: "registry.svg"
    }
    return hash[t] if hash[t]

    "unknown.svg"
  end

  def build_from_results(results:)
    discoverables = []
    counter = 1
#    s (resource URL) t(type) title contact(vcard url)
    results.each do |result|
#      warn "result is #{result.inspect}"

      next if result[:t].to_s =~ /\#Resource/

      icon = match_type_to_icon(type: result[:t].to_s)
      type = result[:t].to_s
      typetag = type.match(/[\#\/](\w+?)$/)[1].downcase
      next if typetag == "dataservice" && result[:servicetype].to_s.empty?  # if it is a dataservice without a service type, then it is a top level FDP
      frozen = result[:contact].to_s
      source = frozen.dup
      source = "No Contact Provided (#{counter})" and counter += 1 unless source
      source.gsub!(/\/\s*$/, "")  # no diference between http://my.org/  and http://my.org
      discoverables << Discoverable.create_or_retrieve(
        source: source,   # mylab.com
        resource: result[:s].to_s,  # https://mylab.com/dist/1234231
        title: result[:title].to_s,  # my mock data
        type: type,  # https://w3.org/#Distribution
        icon: icon, # whatever
        typetag: typetag)  # Distribution
      # discoverables[contact] = [] unless discoverables[contact]
      # discoverables[contact] << { resource: result[:s].to_s, title: result[:title].to_s, type: result[:t].to_s, icon: icon }
    end
    # sort_discoverables(discoverables: discoverables)
    discoverables
  end

  # ths might now be deprecated...
  def sort_discoverables(discoverables:)
    discoverables.each do |provider|  # discoverables["banco"] = [{resource: http,  title: "hello", type: "dataset", icon: ico, contact: "banco"}, {resource: http ...}]
      sorted = discoverables[provider].sort_by { |s| s[:type] }
      discoverables[provider] = sorted
    end
    discoverables
  end
end
