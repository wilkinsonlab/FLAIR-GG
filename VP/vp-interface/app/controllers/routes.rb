require "./lib/fdp"

def set_routes(classes: allclasses) # $th is the test configuration hash
  get "/flair-gg-vp-server" do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
    # Swagger::Blocks.build_root_json(classes)
  end

  get "/flair-gg-vp-server/force-refresh" do
    return [] if File.exist?("./cache/REFRESHING") # multiple browser calls are a problem!
    f = open("./cache/REFRESHING", "w")  # multiple browser calls are a problem!
    f.puts "REFRESHING"
    f.close
    @discoverables = {}
    FDPConfig.new  # initialize
    fdps = FDPConfig::FDPSITES
    fdps.each do |fdp_address|
      warn "working with #{fdp_address}"
      fdp = FDP.new(address: fdp_address, refresh: true)
      hash = fdp.find_discoverables
      @discoverables.merge!(hash)
    end
    File.delete("./cache/REFRESHING")
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/resources" do
    guid = params["guid"]
    @discoverables = {}
    FDPConfig.new  # initialize
    fdps = FDPConfig::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.find_discoverables
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by { |_k, v| v[:type] }.to_h
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/keyword-search" do
    warn "in keyword search now\n\n\n"
    keyword = params["keyword"]
    @discoverables = {}
    FDPConfig.new  # initialize
    fdps = FDPConfig::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.keyword_search(keyword: keyword)
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by { |_k, v| v[:type] }.to_h
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/ontology-search" do
    warn "in ontology search now\n\n\n"
    term = params["uri"]
    @discoverables = {}
    FDPConfig.new # initialize
    fdps = FDPConfig::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.ontology_search(uri: term)
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by { |_k, v| v[:type] }.to_h
    erb :discovered_layout
  end

  get "/flair-gg-vp-server/wordcloud" do
    refresh = params["refresh"]
    refresh ||= "false"
    FDPConfig.new # initialize
    @discoverables = {}
    wc = Wordcloud.new(refresh: refresh)
    @words = wc.count_words
    erb :wordcloud
  end
  get "/flair-gg-vp-server/wordcloud/force-refresh" do
    warn "forced refresh"
    refresh = "true"
    FDPConfig.new # initialize
    @discoverables = {}
    wc = Wordcloud.new(refresh: refresh)
    @words = wc.count_words
    erb :wordcloud
  end
end
