# frozen_string_literal: false

def set_routes(classes: allclasses)
  set :server_settings, timeout: 180
  set :public_folder, "public"

  get "/" do
    redirect '/flair-gg-vp-server/resources'
  end

  get "/flair-gg-vp-server" do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
  end

  get "/flair-gg-vp-server/force-refresh" do
    warn "initializing refresh in routes"
    unless File.exist?("./cache/REFRESHING") # multiple browser calls are a problem!
      VP.restart 
      @discoverables = VP.current_vp.get_resources  # "./lib/metadata_functions"
      FileUtils.rm_f("./cache/servicetypes.json")  # remove the cache
      @services = VP.current_vp.collect_data_services
    end
    redirect '/flair-gg-vp-server/resources'  # before do collect_data_services will be called, and this will refresh
  end

  get "/flair-gg-vp-server/resources" do
    @discoverables = VP.current_vp.get_resources  # "./lib/metadata_functions"
    @message = "All Resources"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/keyword-search" do
    keyword = params["keyword"].strip
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword) # "./lib/vp"
    @message = "Keyword Search Results"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/ontology-search" do
    term = params["uri"].strip
    term = term.gsub(/\S+:/, "") unless term =~ /^http/
    @discoverables = VP.current_vp.ontology_search_shell(term: term) # "./lib/vp"
    @message = "Ontology Search Results"

    erb :discovered_layout
  end

  get "/flair-gg-vp-server/retrieve-services" do
    termuri = params["services"]
    @servicecollection, @commongetparams, @commonpostparams = VP.current_vp.retrieve_sevices(termuri: termuri) # "./lib/vp"
    erb :services_layout
  end

  get "/flair-gg-vp-server/wordcloud" do
    @freqs = Wordcloud.new.count_words # "./lib/wordcloud"
    erb :wordcloud
  end

  get "/flair-gg-vp-server/wordcloud/force-refresh" do
    @discoverables = {}
    @freqs = {}
    if File.exist?("./cache/WCREFRESHING") # multiple browser calls are a problem!
      erb :discovered_layout
    else
      f = open("./cache/WCREFRESHING", "w")  # multiple browser calls are a problem!
      f.puts "WCREFRESHING"
      f.close

      warn "forced refresh"
      wc = Wordcloud.new(refresh: true)
      @freqs = wc.count_words
      warn "received #{@freqs.length}"
      FileUtils.rm_f("./cache/WCREFRESHING")
    end
    erb :wordcloud
  end

  get "/flair-gg-vp-server/refresh-servicetypes" do
    FileUtils.rm_f("./cache/servicetypes.json")  # remove the cache
    @services = VP.current_vp.collect_data_services # refresh
    redirect '/flair-gg-vp-server/resources'  # before do collect_data_services will be called, and this will refresh
  end

  post "/flair-gg-vp-server/execute-data-services" do
    @location, @servicelabel, @results = VP.current_vp.execute_data_services(params: params)
    @servicelabel = @servicelabel.gsub(/\s+/, "_")  # no spaces in service filenames - label leads to jupyter file
    erb :execution_results_layout
  end

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
