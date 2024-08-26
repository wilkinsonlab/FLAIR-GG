# frozen_string_literal: false

require "linkeddata"
require "digest"
require "restclient"
require "json"
require "uri"
require "fileutils"
require "require_all"

require_rel "ontologyservers"
require_rel "serviceoutput_processers"
require_rel "discoverable"
require_rel "common_queries"

class VP
  attr_accessor :networkgraph, :vpconfig, :fdps, :aboutme

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

  def load_fdps_from_cache
    Dir["./cache/*.marsh"].select { |f| !File.directory? File.join("./cache/", f) }.each do |marsh|
      fdp = FDP.load_from_cache(vp: self, marshalled: marsh)
      add_fdp(fdp: fdp)
    end
  end

  def add_fdp(fdp:)
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
    find_discoverables  # things that have been flagged as "VPDiscoverable"
  end

  def find_discoverables

    results = find_discoverables_query(graph: networkgraph)
    discoverables = build_from_results(results: results)
    warn discoverables
    discoverables
  end

  def keyword_search_shell(keyword:)
    warn "in keyword search now\n\n\n"
    keyword_search(keyword: keyword)
  end

  def ontology_search_shell(term:)
    warn "in ontology search shell"
    ontology_search(uri: term)
  end

  def keyword_search(keyword: "")
    keyword = keyword.downcase
    results = keyword_search_query(graph: networkgraph, keyword: keyword)
    discoverables = build_from_results(results: results)
    warn discoverables
    discoverables
  end

  def ontology_search(uri: "")
    results = ontology_search_query(graph: networkgraph, uri: uri)
    discoverables = build_from_results(results: results)
    warn discoverables
    discoverables
  end

  def verbose_annotations
    @graph = networkgraph
    words = []
    results = verbose_annotations_query(graph: networkgraph)

    results.each do |res|
      uri = res[:annot].to_s
      word = ontology_annotations(uri: uri)
      next unless word
      next if word.empty?

      words << word.capitalize
    end
    # end of taxonomy parser

    warn "\n\nSWITCH TO KEYWORDS\n\n"
    results = keyword_annotations_query(graph: networkgraph)
    results.each do |res|
      next if res[:kw].to_s.empty?

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
      warn "in collect data services"
      results = collect_data_services_query(graph: networkgraph)
      prehash = {}
      results.each do |r|
        type = r[:type].to_s
        next if prehash[type]  # already known

        warn "subject type #{type}"
        kw = ontology_annotations(uri: type)
        prehash[type] = kw
      end
      services = prehash.map { |k, v| [k, v] } # remove trailing space and turn into array
      freeze_servicetypes(types: services)
    end
    services
  end

  def retrieve_sevices(termuri:)  #  the URI of the service type
    # hand off to services_functions
    servicecollection = ServiceCollection.new(vpgraph: networkgraph, servicetype: termuri)
    commongetparams = servicecollection.gather_common_parameters(method: "get")
    commonpostparams = servicecollection.gather_common_parameters(method: "post")
    [servicecollection, commongetparams, commonpostparams]
  end

  # 28b2cb8a656a0b9fdbd385d6e86e691f9ccff2f4c8605026c5bfbb2b1d36b4b5
  def execute_data_services(params:)
    endpoints = params.delete("endpoint") # returns an array of endpoints from the checkboxes
    results = {}
    endpoints.each do |ep|
      endpoint = CGI.unescape(ep)
      if params["_request_body"]
        result = Service::execute_post(endpoint: endpoint, body: params)
      else
        result = Service::execute_get(endpoint: endpoint, params: params)
      end
      results[endpoint] = result.body if result
    end
    downloadlocation = process_and_upload_output(results: results) # in serviceoutput_processors/general.rb
    [downloadlocation, results]
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
      typetag = type.match(%r{[\#/](\w+?)$})[1].downcase
      # if it is a dataservice without a service type, then it is a top level FDP
      next if typetag == "dataservice" && result[:servicetype].to_s.empty?

      frozen = result[:contact].to_s
      source = frozen.dup
      source = "No Contact Provided (#{counter})" and counter += 1 unless source
      source.gsub!(%r{/\s*$}, "")  # no diference between http://my.org/  and http://my.org
      discoverables << Discoverable.create_or_retrieve(
        source: source,   # mylab.com
        resource: result[:s].to_s,  # https://mylab.com/dist/1234231
        title: result[:title].to_s,  # my mock data
        type: type,  # https://w3.org/#Distribution
        icon: icon, # whatever
        typetag: typetag
      )  # Distribution
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
