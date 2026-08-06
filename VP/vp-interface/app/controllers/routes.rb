# frozen_string_literal: false

require 'sinatra/base'
require 'json'
require 'yaml'
require 'fileutils'

# Defines all HTTP routes for the FLAIR-GG Virtual Platform (VP) server.
#
# Subclasses +Sinatra::Base+ so that routes are a first-class, independently
# documentable layer.  {ApplicationController} adds VP initialisation.
#
# Route handlers depend on:
# - {VP.current_vp}       — the singleton VP instance initialised by {ApplicationController}
# - {Wordcloud}           — word-cloud frequency builder
# - {ServiceCollection}   — FAIR service aggregation
class VPRoutes < Sinatra::Base
  set :server_settings, timeout: 180
  set :public_folder, 'public'
  set :views, 'app/views'
  enable :logging

  helpers do
    # Content-negotiates between +text/html+ (renders +html_view+) and
    # +application/json+ (renders +json_body+). This is an API-first service
    # (the HTML views are a secondary convenience, not the primary
    # interface), so JSON is the default: HTML is only served when the
    # client's *top* Accept preference is exactly +text/html+ (e.g. a
    # browser navigating directly to the URL). Any other Accept value -
    # missing entirely, +*/*+, +application/json+, or anything else - gets
    # JSON, so API clients work correctly without having to know to ask for
    # it explicitly.
    #
    # @param html_view [Symbol] ERB template to render for +text/html+
    # @param json_body [#to_json] object to serialize as JSON
    def respond_with(html_view:, json_body:)
      if request.accept.first.to_s == 'text/html'
        halt erb(html_view)
      else
        content_type :json
        halt json_body.to_json
      end
    end
  end

  # @!group Filters and CORS

  # Runs before every request.  Sets the CORS allow-origin header and populates
  # +@services+ (the cached list of FAIR data-service types) so that navigation
  # views are always up to date.
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    @services = VP.current_vp.collect_data_services
  end

  # @!method options_preflight
  # Handles CORS preflight OPTIONS requests for every path.
  #
  # @return [Integer] HTTP 200
  options '*' do
    response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end

  # @!group Redirects and OpenAPI

  # @!method get_root
  # Redirects the bare root to the resources listing.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get '/' do
    redirect '/flair-gg-vp-server/resources'
  end

  # @!method get_openapi_root
  # Returns this VP server's OpenAPI 3 document. Generated from the request
  # specs (see +spec/spec_helper.rb+ and +doc/openapi.yaml+) rather than
  # hand-maintained - run <tt>OPENAPI=1 bundle exec rspec</tt> to regenerate
  # it after changing a route.
  #
  # @return [String] JSON-encoded OpenAPI 3 document
  OPENAPI_DOC_PATH = File.expand_path('../../doc/openapi.yaml', __dir__)

  get %r{/flair-gg-vp-server/?} do
    content_type :json
    unless File.exist?(OPENAPI_DOC_PATH)
      halt 404, { error: 'doc/openapi.yaml not generated yet - run OPENAPI=1 bundle exec rspec' }.to_json
    end
    YAML.load_file(OPENAPI_DOC_PATH).to_json
  end

  # @!group Cache Refresh

  # @!method get_force_refresh
  # Convenience redirect: triggers a full network refresh, then lands on the
  # resources page.  The {#get_resources_force_refresh} handler performs the
  # actual work.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources/force-refresh+
  get %r{/flair-gg-vp-server/force-refresh/?} do
    redirect '/flair-gg-vp-server/resources/force-refresh'
  end

  # @!method get_resources_force_refresh
  # Re-discovers all FDP nodes in the FAIR network, rebuilds the RDF graph, and
  # reloads the data-service type cache before redirecting to the resources page.
  #
  # A lock file (+./cache/REFRESHING+) prevents concurrent refresh runs (e.g. from
  # multiple simultaneous browser requests).
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get %r{/flair-gg-vp-server/resources/force-refresh/?} do
    warn 'initializing refresh in routes'
    unless File.exist?('./cache/REFRESHING')
      # VP.restart
      @discoverables = VP.current_vp.get_resources
      @services = VP.current_vp.refresh_service_types
    end
    redirect '/flair-gg-vp-server/resources'
  end

  # @!group Resource Discovery

  # @!method get_resources
  # Lists all VPDiscoverable resources known to this VP across the FAIR network.
  #
  # Content negotiation:
  # - +text/html+        → renders +:discovered_layout+
  # - +application/json+ → returns the discoverables array as JSON
  #
  # @return [String, HTML] JSON array of {Discoverable} objects, or the
  #   +:discovered_layout+ ERB template
  get %r{/flair-gg-vp-server/resources/?} do
    @discoverables = VP.current_vp.get_resources
    @message = 'All Resources'
    respond_with(html_view: :discovered_layout, json_body: @discoverables)
  end

  # @!group Keyword Search

  # @!method get_keyword_search(keyword)
  # Searches the VP network for resources whose metadata contains +keyword+.
  # The search is case-insensitive and delegated to {VP#keyword_search_shell}.
  #
  # @param keyword [String] query parameter; the term to search for
  #
  # Content negotiation:
  # - +text/html+        → renders +:discovered_layout+
  # - +application/json+ → returns matching {Discoverable} objects as JSON
  #
  # @return [String, HTML] matching resources
  get %r{/flair-gg-vp-server/keyword-search/?} do
    keyword = params['keyword'].strip
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword)
    @message = 'Keyword Search Results'
    respond_with(html_view: :discovered_layout, json_body: @discoverables)
  end

  # @!method post_keyword_search(body)
  # JSON-body equivalent of {#get_keyword_search}.
  # Accepts a JSON object with a +keyword+ field so that programmatic clients
  # can POST rather than encode a query string.
  #
  # @param [Hash] body JSON object, e.g. <tt>{ "keyword": "cancer" }</tt>
  #
  # Content negotiation: same as {#get_keyword_search}.
  #
  # @return [String, HTML] matching resources
  post %r{/flair-gg-vp-server/keyword-search/?} do
    data = JSON.parse request.body.read.to_s
    keyword = data['keyword'] ? data['keyword'].strip : ''
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword)
    @message = 'Keyword Search Results'
    respond_with(html_view: :discovered_layout, json_body: @discoverables)
  end

  # @!group Ontology Search

  # @!method get_ontology_search(uri)
  # Searches the VP network for resources annotated with the given ontology term URI.
  #
  # The +uri+ parameter may be supplied as a full HTTP URI or as a prefixed CURIE
  # (e.g. +edam:format_3790+); any non-HTTP prefix is stripped before the search.
  #
  # @param uri [String] query parameter; the ontology term URI or CURIE to search for
  #
  # Content negotiation:
  # - +text/html+        → renders +:discovered_layout+
  # - +application/json+ → returns matching {Discoverable} objects as JSON
  #
  # @return [String, HTML] matching resources
  get %r{/flair-gg-vp-server/ontology-search/?} do
    @discoverables = VP.current_vp.ontology_search_shell(term: params['uri'])
    @message = 'Ontology Search Results'
    respond_with(html_view: :discovered_layout, json_body: @discoverables)
  end

  # @!method post_ontology_search(body)
  # JSON-body equivalent of {#get_ontology_search}.
  #
  # @param [Hash] body JSON object, e.g. <tt>{ "uri": "http://edamontology.org/format_3790" }</tt>
  #   The +uri+ value undergoes the same CURIE-stripping as the GET variant.
  #
  # Content negotiation: same as {#get_ontology_search}.
  #
  # @return [String, HTML] matching resources
  post %r{/flair-gg-vp-server/ontology-search/?} do
    data = JSON.parse request.body.read.to_s
    @discoverables = VP.current_vp.ontology_search_shell(term: data['uri'] || '')
    @message = 'Ontology Search Results'
    respond_with(html_view: :discovered_layout, json_body: @discoverables)
  end

  # @!group Service Retrieval

  # @!method get_retrieve_services(services)
  # Returns the collection of FAIR data services that match a given service-type URI,
  # together with their common GET and POST parameters.
  #
  # Used by the UI to present a parameterised form before the user executes services.
  # Delegates to {VP#retrieve_sevices} (note: intentional typo in the method name).
  #
  # @param services [String] query parameter; the ontology URI identifying the service type
  #   (e.g. +http://edamontology.org/operation_3436+)
  #
  # Content negotiation:
  # - +text/html+        → renders +:services_layout+ (form-based interface)
  # - +application/json+ → returns a minimized service-collection JSON object
  #   (RDF graph stripped; only endpoints, parameters, and metadata retained)
  #
  # @return [String, HTML] service collection for the requested type
  get %r{/flair-gg-vp-server/retrieve-services/?} do
    termuri = params['services']
    @servicecollection, @commongetparams, @commonpostparams, @accept = VP.current_vp.retrieve_sevices(termuri: termuri)
    @minimized_collection = @servicecollection.minimize_service_collection(
      commongetparams: @commongetparams, commonpostparams: @commonpostparams
    )
    respond_with(html_view: :services_layout, json_body: @minimized_collection)
  end

  # @!group Service Execution

  # @!method post_execute_data_services(content_type)
  # Executes one or more FAIR data services registered in the VP network and
  # aggregates their results.  This is the primary portal into the federated
  # network of APIs discovered through connected FAIR Data Point (FDP) nodes.
  #
  # The route dispatches on +Content-Type+ and supports two calling conventions:
  #
  # ---
  # ## Mode 1 — JSON API  (+Content-Type: application/json+)
  #
  # The request body must be a JSON object (or a single-element JSON array whose
  # first element is a JSON object) with the following fields:
  #
  #   {
  #     "uri":           "<service-type URI>",          # required; last path/fragment segment
  #                                                     #   becomes the Jupyter notebook filename
  #     "service_list":  ["<endpoint_url>", ...],       # required; endpoints to fan out to
  #     "_request_body": { ... },                       # optional; if present each endpoint
  #                                                     #   is called via POST with this body
  #     "accept":        "<media-type>"                 # optional; forwarded as Accept header
  #                                                     #   to each remote endpoint
  #   }
  #
  # On success (+Accept: application/json+) returns:
  #   {
  #     "location": "<LDP server URL where aggregated results were uploaded>",
  #     "jupyter":  "<JupyterHub analytics notebook URL>",
  #     "results":  { "<endpoint_url>": "<response body>", ... }
  #   }
  #
  # ---
  # ## Mode 2 — HTML form  (any other +Content-Type+)
  #
  # Parameters are read from the Sinatra +params+ hash as submitted by the
  # +:services_layout+ HTML form.  Expected fields:
  #
  # - +servicelabel+   — human-readable service name; spaces replaced with underscores
  #                      to produce the Jupyter notebook filename
  # - +endpoint+       — one or more endpoint URLs (checkbox array); absent = no-op
  # - +accept+         — media type to request from each endpoint
  # - +_request_body+  — optional JSON body; if present each endpoint is called via POST,
  #                      otherwise a GET call is made with remaining params as query parameters
  # - all other params — forwarded as query-string parameters on GET calls
  #
  # On success with +Accept: text/html+ renders +:execution_results_layout+.
  # On success with +Accept: application/json+ returns:
  #   {
  #     "location": "<LDP server URL>",
  #     "jupyter":  "<service label string>"
  #   }
  #
  # ---
  # In both modes, responses from all endpoints are aggregated and uploaded to the
  # project LDP server via +process_and_upload_output+ (see
  # +lib/serviceoutput_processers/general.rb+).  The returned +location+ is the
  # URL of that uploaded resource.
  #
  # @param content_type [String] +application/json+ selects Mode 1; anything else selects Mode 2
  # @return [String, HTML] Mode 1 always responds with JSON; Mode 2 content-negotiates
  #   (see {#respond_with})
  post %r{/flair-gg-vp-server/execute-data-services/?} do
    if request.content_type == 'application/json'
      j = JSON.parse(request.body.read.to_s)
      j = j.first if j.is_a? Array
      # {uri: serviceuri,
      #  _request_body: {json: data},   # optional; triggers POST if present, GET otherwise
      #  service_list: [endpoint, endpoint, endpoint]
      # }
      serviceuri = j['uri'] ? j['uri'].gsub(%r{.*[/\#](\S+)}, '\1') : 'unknown'
      servicelabel = VP.current_vp.build_service_label(serviceuri)
      analytics = VP.current_vp.notebook_url(servicelabel)
      location, results = VP.current_vp.execute_data_services_api(json: j)
      content_type :json
      { 'location' => location, 'jupyter' => analytics, 'results' => results }.to_json
    else
      @servicelabel = VP.current_vp.build_service_label(params['servicelabel'])
      @location, @results = VP.current_vp.execute_data_services(params: params)
      respond_with(html_view: :execution_results_layout,
                   json_body: { 'location' => @location, 'jupyter' => @servicelabel })
    end
  end

  # @!group Word Cloud

  # @!method get_wordcloud
  # Renders a word-cloud visualisation of keyword/ontology annotations found
  # across all discoverable resources in the VP network.
  #
  # Word frequencies are computed by {Wordcloud#count_words} using the cached
  # network graph; no remote calls are made on this path.
  #
  # @return [HTML] renders the +:wordcloud+ ERB template
  get %r{/flair-gg-vp-server/wordcloud/?} do
    @freqs = Wordcloud.new.count_words
    erb :wordcloud
  end

  # @!method get_wordcloud_force_refresh
  # Re-fetches annotation data from the network and regenerates the word-cloud
  # cache, then renders the word-cloud page with fresh frequencies.
  #
  # A lock file (+./cache/WCREFRESHING+) prevents concurrent refresh runs.  If a
  # refresh is already in progress the stale (empty) word-cloud page is returned
  # immediately.
  #
  # @return [HTML] renders the +:wordcloud+ ERB template
  get %r{/flair-gg-vp-server/wordcloud/force-refresh/?} do
    @discoverables = {}
    @freqs = {}
    if Wordcloud.refreshing?
      erb :discovered_layout
    else
      warn 'forced refresh'
      @freqs = Wordcloud.new(refresh: true).count_words
      warn "received #{@freqs.length}"
    end
    erb :wordcloud
  end

  # @!group Service Type Management

  # @!method get_refresh_servicetypes
  # Invalidates the service-type cache and rebuilds it from the live network
  # graph, then redirects to the resources page.  Intended for use via the browser UI.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get %r{/flair-gg-vp-server/refresh-servicetypes/?} do
    @services = VP.current_vp.refresh_service_types
    redirect '/flair-gg-vp-server/resources'
  end

  # @!method get_servicetypes
  # Returns the current list of FAIR data-service types known to this VP.
  # Always forces a cache refresh before responding.
  # Intended for programmatic / API access only.
  #
  # @return [String] JSON array of +[uri, label]+ pairs representing each service type
  get %r{/flair-gg-vp-server/servicetypes/?} do
    @services = VP.current_vp.refresh_service_types
    content_type :json
    @services.to_json
  end
end
