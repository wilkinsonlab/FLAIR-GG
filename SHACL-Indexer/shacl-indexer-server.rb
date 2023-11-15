require "rdf"
require "sparql"
require "rest-client"
require "json"
require "time"
require "sinatra"
require "haml"
# require "sinatra/partial"
require "erb"
# require "uuidtools"
require "fileutils"
require "open3"
require "./engine"

# set :public_folder, '/front-end/public'
set :port, 6000

get "/" do
  haml :index, format: :html5
end

post "/index/" do
  url = JSON.parse(request.body.read)["url"]
  @shacl = index(url: url)
  content_type "text/turtle"
  @shacl

  #haml :result
end

# --------------------------- logic here

def index(url:)
  
  engine = Engine.new
  rdf_index = engine.extract_patterns(endpoint_urls: url)
  engine.shacl_generator(patterns_hash: rdf_index)
end