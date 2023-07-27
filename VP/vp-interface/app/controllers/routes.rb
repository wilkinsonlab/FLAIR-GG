require "./lib/fdp"

def set_routes(classes: allclasses) # $th is the test configuration hash
  get '/flair-gg-vp-server' do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
    # Swagger::Blocks.build_root_json(classes)
  end

  get '/flair-gg-vp-server/force-refresh' do
    @discoverables = Hash.new
    fdps = FDP::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: true)
      hash = fdp.find_discoverables
      @discoverables.merge!(hash)
    end
    erb :discovered_layout
  end

  get '/flair-gg-vp-server/resources' do
    guid = params['guid']
    @discoverables = Hash.new
    fdps = FDP::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.find_discoverables
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by {|k,v| v[:type]}.to_h
    erb :discovered_layout
  end

  get '/flair-gg-vp-server/keyword-search' do
    warn "in keyword search now\n\n\n"
    keyword = params['keyword']
    @discoverables = Hash.new
    fdps = FDP::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.keyword_search(keyword: keyword)
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by {|k,v| v[:type]}.to_h
    erb :discovered_layout
    # content_type 'application/ld+json'
    # guid = params['guid']
    # graph = @metadata.graph
    # graph.dump(:jsonld)
  end

  get '/flair-gg-vp-server/ontology-search' do
    warn "in ontology search now\n\n\n"
    term = params['uri']
    @discoverables = Hash.new
    fdps = FDP::FDPSITES
    fdps.each do |fdp_address|
      fdp = FDP.new(address: fdp_address, refresh: false)
      hash = fdp.ontology_search(uri: term)
      @discoverables.merge!(hash)
    end
    @discoverables = @discoverables.sort_by {|k,v| v[:type]}.to_h
    erb :discovered_layout
    # content_type :json
    # guid = params['guid']
    # response = @metadata.hash.to_json || '{}'
    # response
  end

  get '/flair-gg-vp-server/wordcloud' do
    refresh = params['refresh']
    @discoverables = Hash.new
    wc = Wordcloud.new(refresh: refresh)
    @words = wc.count_words
    erb :wordcloud
  end
end
