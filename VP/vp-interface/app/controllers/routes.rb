
def set_routes(classes: allclasses)

  set :server_settings, :timeout => 180
  set :public_folder, 'public'

  get "/flair-gg-vp-server" do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
  end

  get "/flair-gg-vp-server/force-refresh" do
    warn "initializing refresh in routes"
    VP.restart unless File.exist?("./cache/REFRESHING") # multiple browser calls are a problem!
    @discoverables = VP.current_vp.get_resources  # "./lib/metadata_functions"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/resources" do
    @discoverables = VP.current_vp.get_resources  # "./lib/metadata_functions"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/keyword-search" do
    keyword = params["keyword"]
    @discoverables = VP.current_vp.keyword_search_shell(keyword: keyword) # "./lib/fdp"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/ontology-search" do
    term = params["uri"]
    term = term.gsub(/\S+\:/, "") unless term =~ /^http/
    @discoverables = VP.current_vp.ontology_search_shell(term: term)  # "./lib/fdp"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/retrieve-services" do
    term = params["services"]
    @discoverables = VP.current_vp.retrieve_sevices(term: term)  # "./lib/fdp"
    erb :services_layout
  end

  get "/flair-gg-vp-server/wordcloud" do
    @freqs = Wordcloud.new.count_words  # "./lib/wordcloud"
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

  before do
    @services = VP.current_vp.collect_data_services

  end

end
