# frozen_string_literal: false

# Defines all Sinatra HTTP routes for the FLAIR-GG Virtual Platform (VP) server.
#
# Called once at application startup to register every route with the Sinatra DSL.
# A +before+ filter runs on every request to populate +@services+ (the cached list
# of FAIR data-service types) so that navigation menus are always available in views.
#
# @param classes [Array<Class>] Swagger::Blocks API classes used to build the OpenAPI
#   JSON root document. Defaults to +allclasses+ (application-wide constant).
# @return [void]
def set_routes(classes: allclasses)
  set :server_settings, timeout: 180
  set :public_folder, 'public'

  # @!group Redirects and OpenAPI

  # Redirects the bare root to the resources listing.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get '/' do
    redirect '/flair-gg-vp-server/resources'
  end

  # Returns the OpenAPI / Swagger root JSON document for this VP server.
  #
  # @return [String] JSON-encoded OpenAPI root document built from +classes+
  get %r{/flair-gg-vp-server/?} do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
  end

  # @!group Cache Refresh

  # Convenience redirect: triggers a full network refresh, then lands on the
  # resources page. The +before+ filter and the resources/force-refresh handler
  # together perform the actual work.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources/force-refresh+
  get %r{/flair-gg-vp-server/force-refresh/?} do
    redirect '/flair-gg-vp-server/resources/force-refresh'
  end

  # Re-discovers all FDP nodes in the FAIR network, rebuilds the RDF graph, and
  # reloads the data-service type cache before redirecting to the resources page.
  #
  # A lock file (+./cache/REFRESHING+) prevents concurrent refresh runs (e.g. from
  # multiple simultaneous browser tabs or requests).
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get %r{/flair-gg-vp-server/resources/force-refresh/?} do
    warn 'initializing refresh in routes'
    unless File.exist?('./cache/REFRESHING') # multiple browser calls are a problem!
      VP.restart
      @discoverables = VP.current_vp.get_resources # "./lib/metadata_functions"
      FileUtils.rm_f('./cache/servicetypes.json') # remove the cache
      @services = VP.current_vp.collect_data_services
    end
    redirect '/flair-gg-vp-server/resources'
  end

  # @!group Resource Discovery

  # Lists all VPDiscoverable resources known to this VP across the FAIR network.
  #
  # Content negotiation:
  # - +text/html+        → renders +:discovered_layout+ (browseable page)
  # - +application/json+ → returns the discoverables array as JSON
  #
  # @return [String, HTML] JSON array of {Discoverable} objects, or the
  #   +:discovered_layout+ ERB template
  # @raise [406] if the client +Accept+ header cannot be satisfied
  get %r{/flair-gg-vp-server/resources/?} do
    @discoverables = VP.current_vp.get_resources # "./lib/metadata_functions"
    @message = 'All Resources'
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :discovered_layout
      when 'application/json'
        content_type :json
        halt @discoverables.to_json
      end
    end
    error 406
  end

  # @!group Keyword Search

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
  # @raise [406] if the client +Accept+ header cannot be satisfied
  get %r{/flair-gg-vp-server/keyword-search/?} do
    keyword = params['keyword'].strip
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword) # "./lib/vp"
    @message = 'Keyword Search Results'
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :discovered_layout
      when 'application/json'
        content_type :json
        halt @discoverables.to_json
      end
    end
    error 406
  end

  # JSON-body equivalent of +GET /flair-gg-vp-server/keyword-search+.
  # Accepts a JSON object with a +keyword+ field so that programmatic clients
  # can POST rather than encode a query string.
  #
  # @param [Hash] body JSON object, e.g. <tt>{ "keyword": "cancer" }</tt>
  #
  # Content negotiation: same as the GET variant.
  #
  # @return [String, HTML] matching resources
  # @raise [406] if the client +Accept+ header cannot be satisfied
  post %r{/flair-gg-vp-server/keyword-search/?} do
    data = JSON.parse request.body.read.to_s
    keyword = data['keyword'] ? data['keyword'].strip : ''
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword) # "./lib/vp"
    @message = 'Keyword Search Results'
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :discovered_layout
      when 'application/json'
        content_type :json
        halt @discoverables.to_json
      end
    end
    error 406
  end

  # @!group Ontology Search

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
  # @raise [406] if the client +Accept+ header cannot be satisfied
  get %r{/flair-gg-vp-server/ontology-search/?} do
    term = params['uri'].strip
    term = term.gsub(/\S+:/, '') unless term =~ /^http/
    @discoverables = VP.current_vp.ontology_search_shell(term: term) # "./lib/vp"
    @message = 'Ontology Search Results'
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :discovered_layout
      when 'application/json'
        content_type :json
        halt @discoverables.to_json
      end
    end
    error 406
  end

  # JSON-body equivalent of +GET /flair-gg-vp-server/ontology-search+.
  #
  # @param [Hash] body JSON object, e.g. <tt>{ "uri": "http://edamontology.org/format_3790" }</tt>
  #   The +uri+ value undergoes the same CURIE-stripping as the GET variant.
  #
  # Content negotiation: same as the GET variant.
  #
  # @return [String, HTML] matching resources
  # @raise [406] if the client +Accept+ header cannot be satisfied
  post %r{/flair-gg-vp-server/ontology-search/?} do
    data = JSON.parse request.body.read.to_s
    term = data['uri'] ? data['uri'].strip : ''
    term = term.gsub(/\S+:/, '') unless term =~ /^http/
    @discoverables = VP.current_vp.ontology_search_shell(term: term) # "./lib/vp"
    @message = 'Ontology Search Results'
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :discovered_layout
      when 'application/json'
        content_type :json
        halt @discoverables.to_json
      end
    end
    error 406
  end

  # @!group Service Retrieval

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
  # @raise [406] if the client +Accept+ header cannot be satisfied
  get %r{/flair-gg-vp-server/retrieve-services/?} do
    termuri = params['services']
    @servicecollection, @commongetparams, @commonpostparams, @accept = VP.current_vp.retrieve_sevices(termuri: termuri) # "./lib/vp"
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb :services_layout
      when 'application/json'
        @minimized_collection = @servicecollection.minimize_service_collection(commongetparams: @commongetparams,
                                                                               commonpostparams: @commonpostparams)
        @servicecollection.vpgraph = nil
        content_type :json
        response = @minimized_collection.to_json
        halt response
      end
    end
    error 406
  end

  # @!group Service Execution

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
  # - +servicelabel+   — human-readable service name; spaces are replaced with underscores
  #                      to produce the Jupyter notebook filename
  # - +endpoint+       — one or more endpoint URLs (checkbox array); absent = no-op (returns nil)
  # - +accept+         — media type to request from each endpoint
  # - +_request_body+  — optional JSON body; if present each endpoint is called via POST,
  #                      otherwise a GET call is made with remaining params as query parameters
  # - all other params — forwarded as query-string parameters on GET calls
  #
  # On success with +Accept: text/html+ renders +:execution_results_layout+.
  # On success with +Accept: application/json+ returns:
  #   {
  #     "location": "<LDP server URL>",
  #     "jupyter":  "<service label string>"   # NOTE: label only, not a full URL (unlike Mode 1)
  #   }
  #
  # ---
  # In both modes, responses from all endpoints are aggregated and uploaded to the
  # project LDP server via +process_and_upload_output+ (see
  # +lib/serviceoutput_processers/general.rb+).  The returned +location+ is the
  # URL of that uploaded resource.
  #
  # @param [String] Content-Type  +application/json+ selects Mode 1; anything else selects Mode 2
  # @return [String, HTML] response format determined by the +Accept+ request header
  # @raise [406] if the client +Accept+ header cannot be satisfied by either branch
  post %r{/flair-gg-vp-server/execute-data-services/?} do
    # three possibilities:
    # 1) they send key/value pairs as params from form interface
    # 2) they send _request_body from the form interfaces
    # 3) they send JSON as the body
    if request.content_type == 'application/json'
      j = JSON.parse(request.body.read.to_s)
      j = j.first if j.is_a? Array
      # {uri: serviceuri,
      #  _request_body: {json: data},   # optional; triggers POST if present, GET otherwise
      #  service_list: [endpoint, endpoint, endpoint]
      # }
      serviceuri = j['uri'] ? j['uri'].gsub(%r{.*[/\#](\S+)}, '\1') : 'unknown'
      servicelabel = serviceuri.downcase.gsub(/\s+/, '_')
      analytics = "https://wilkinsonlab.github.io/FLAIR-GG-Analytics/lab/index.html?path=FLAIR-GG%2F#{servicelabel}.ipynb"
      location, results = VP.current_vp.execute_data_services_api(json: j)
      request.accept.each do |type|
        case type.to_s
        when 'application/json'
          content_type :json
          halt({ 'location' => location, 'jupyter' => analytics, 'results' => results }.to_json)
        end
      end
    else
      @servicelabel = params['servicelabel'].downcase.gsub(/\s+/, '_') # no spaces in service filenames - label leads to jupyter file
      @location, @results = VP.current_vp.execute_data_services(params: params)

      request.accept.each do |type|
        case type.to_s
        when 'text/html'
          halt erb :execution_results_layout
        when 'application/json'
          content_type :json
          halt({ 'location' => @location, 'jupyter' => @servicelabel }.to_json)
        end
      end
    end
    error 406
  end

  # @!group Word Cloud

  # Renders a word-cloud visualisation of the keyword/ontology annotations found
  # across all discoverable resources in the VP network.
  #
  # Word frequencies are computed by {Wordcloud#count_words} using the cached
  # network graph; no network calls are made on this path.
  #
  # @return [HTML] renders the +:wordcloud+ ERB template
  get %r{/flair-gg-vp-server/wordcloud/?} do
    @freqs = Wordcloud.new.count_words # "./lib/wordcloud"
    erb :wordcloud
  end

  # Re-fetches annotation data from the network and regenerates the word-cloud cache,
  # then renders the word-cloud page with fresh frequencies.
  #
  # A lock file (+./cache/WCREFRESHING+) prevents concurrent refresh runs.  If a
  # refresh is already in progress the stale (empty) word-cloud page is returned
  # immediately.
  #
  # @return [HTML] renders the +:wordcloud+ ERB template
  get %r{/flair-gg-vp-server/wordcloud/force-refresh/?} do
    @discoverables = {}
    @freqs = {}
    if File.exist?('./cache/WCREFRESHING') # multiple browser calls are a problem!
      erb :discovered_layout
    else
      f = open('./cache/WCREFRESHING', 'w') # multiple browser calls are a problem!
      f.puts 'WCREFRESHING'
      f.close

      warn 'forced refresh'
      wc = Wordcloud.new(refresh: true)
      @freqs = wc.count_words
      warn "received #{@freqs.length}"
      FileUtils.rm_f('./cache/WCREFRESHING')
    end
    erb :wordcloud
  end

  # @!group Service Type Management

  # Invalidates the service-type cache and rebuilds it from the live network graph,
  # then redirects to the resources page. Intended for use via the browser UI.
  #
  # @return [void] issues a 302 redirect to +/flair-gg-vp-server/resources+
  get %r{/flair-gg-vp-server/refresh-servicetypes/?} do
    FileUtils.rm_f('./cache/servicetypes.json') # remove the cache
    @services = VP.current_vp.collect_data_services # refresh
    redirect '/flair-gg-vp-server/resources'
  end

  # Returns the current list of FAIR data-service types known to this VP.
  # Always forces a cache refresh before responding.
  # Intended for programmatic / API access only.
  #
  # @return [String] JSON array of +[uri, label]+ pairs representing each service type
  # @raise [406] if the client +Accept+ header cannot be satisfied
  get %r{/flair-gg-vp-server/servicetypes/?} do
    FileUtils.rm_f('./cache/servicetypes.json') # remove the cache
    @services = VP.current_vp.collect_data_services # refresh
    request.accept.each do |type|
      case type.to_s
      when 'application/json'
        content_type :json
        halt @services.to_json
      end
    end
    error 406
  end

  # @!group Filters

  # Populates +@services+ before every request so that navigation views always
  # have access to the current list of data-service types.  Uses the on-disk cache
  # when available; rebuilds from the RDF network graph otherwise.
  before do
    @services = VP.current_vp.collect_data_services
  end

  # get '/login' do
  #   redirect '/auth/ls_aai'
  # end

  # # Callback route after OIDC authentication
  # get '/auth/ls_aai/callback' do
  #   auth = request.env['omniauth.auth']
  #   # Here you would typically save the auth info or tokens
  #   # For simplicity, let's just show what's received:
  #   puts auth.to_json
  #   "Login successful. Here's your auth info: #{auth.to_json}"
  # end

  # # Example protected route
  # get '/protected' do
  #   token = request.env['HTTP_AUTHORIZATION']&.split(' ')&.last
  #   if authorize_user(token)
  #     "Welcome! You are authorized to access this service."
  #   else
  #     status 401
  #     "Unauthorized"
  #   end
  # end

  # # Failure route for authentication errors
  # get '/auth/failure' do
  #   "Authentication failed: #{params['message']}"
  # end
  # =========================== AUTH
  # use OmniAuth::Builder do
  #   provider :openid_connect,
  #            :name => 'ls_aai',
  #            :issuer => 'your_issuer_url',
  #            :client_id => 'your_client_id',
  #            :client_secret => 'your_client_secret',
  #            :scope => 'openid profile email',
  #            :response_type => 'code',
  #            :redirect_uri => 'your_callback_url',
  #            :discovery => true
  # end

  # # Helper function to authorize user
  # def authorize_user(token)
  #   payload = JWT.decode(token, nil, false)[0]
  #   payload['permissions']&.include?('access_to_service')
  # end
end
