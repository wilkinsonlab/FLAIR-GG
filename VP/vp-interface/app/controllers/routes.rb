require "./lib/fdp"

def set_routes(classes: allclasses)

  set :server_settings, :timeout => 180

  get "/flair-gg-vp-server" do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
  end

  get "/flair-gg-vp-server/force-refresh" do
    warn "initializing refresh in routes"
    @discoverables = {}
    unless File.exist?("./cache/REFRESHING") # multiple browser calls are a problem!
      refresh_cache
    end    
    @discoverables = @discoverables.sort_by { |_k, v| v[:type] }.to_h  # "./lib/metadata_functions"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/resources" do
    guid = params["guid"]
    @discoverables = get_resources.sort_by { |_k, v| v[:type] }.to_h  # "./lib/metadata_functions"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/keyword-search" do
    keyword = params["keyword"]
    @discoverables = keyword_search_shell(keyword: keyword).sort_by { |_k, v| v[:type] }.to_h  # "./lib/fdp"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/ontology-search" do
    term = params["uri"]
    term = term.gsub(/\S+\:/, "") unless term =~ /^http/
    @discoverables = ontology_search_shell(term: term).sort_by { |_k, v| v[:type] }.to_h  # "./lib/fdp"
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/wordcloud" do
    FDPConfig.new # initialize
    @words = Wordcloud.new.count_words  # "./lib/wordcloud"
    erb :wordcloud
  end

  get "/flair-gg-vp-server/wordcloud/force-refresh" do
    @discoverables = {}
    @words = {}
    if File.exist?("./cache/WCREFRESHING") # multiple browser calls are a problem!
      erb :discovered_layout
    else
      f = open("./cache/WCREFRESHING", "w")  # multiple browser calls are a problem!
      f.puts "WCREFRESHING"
      f.close

      warn "forced refresh"
      refresh = "true"
      FDPConfig.new # initialize
      @discoverables = {}
      wc = Wordcloud.new(refresh: refresh)
      @words = wc.count_words
      File.delete("./cache/WCREFRESHING") if File.exist?("./cache/WCREFRESHING")
    end
    erb :wordcloud
  end
end
