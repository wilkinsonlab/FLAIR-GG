
def set_routes(classes: allclasses) # $th is the test configuration hash
  
  get '/fsp-harvester-server' do
    content_type :json
    response.body = JSON.dump(Swagger::Blocks.build_root_json(classes))
    #Swagger::Blocks.build_root_json(classes)
  end

  get '/fsp-harvester-server/links' do
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    @html = @links.map{|l| l.to_html}
    @html = @html.join("\n")
    @id = guid
    erb :html_links_layout
  end

  get '/fsp-harvester-server/ld' do
    content_type "application/ld+json"
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    @metadata = FspHarvester::Utils.gather_metadata_from_describedby_links(links: @links, metadata: @metadata)
    graph = @metadata.graph
    graph.dump(:jsonld)
  end

  get '/fsp-harvester-server/json' do
    content_type :json
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    response = @metadata.hash.to_json || '{}'
    response

  end

  get '/fsp-harvester-server/warnings' do
    content_type :json
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    response = @metadata.warnings.to_json || '{}'
    response
  end

  get '/fsp-harvester-server/ld-by-old-workflow' do
    content_type "application/ld+json"
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    meta = HarvesterTools::BruteForce.begin_brute_force(guid: guid, metadata: @metadata, links: @links)
    graph = meta.graph
    graph.dump(:jsonld)
  end

  get '/fsp-harvester-server/json-by-old-workflow' do
    content_type :json
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    meta = HarvesterTools::BruteForce.begin_brute_force(guid: guid, metadata: @metadata, links: @links)
    hash = meta.hash
    hash.to_json
  end
  get '/fsp-harvester-server/champion-warnings' do
    content_type :json
    guid = params['guid']
    @links, @metadata = HarvesterTools::Utils.resolve_guid(guid: guid)
    response = @metadata.warnings.to_json || '{}'
    response
  end


end

