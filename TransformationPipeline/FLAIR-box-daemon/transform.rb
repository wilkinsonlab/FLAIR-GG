require "sinatra"
require "rest-client"
require "./http_utils"
require "open3"

include HTTPUtils

get "/" do
  update
  yarrrml_substitute
  execute
  load_flair
  cleanup
  # metadata_update
  "Execution complete.  See docker log for errors (if any)\n\n"
end

def update
  warn "first open3 git pull"
  o, e, _s = Open3.capture3("cd FLAIR-GG && git pull")
  warn "second open3 copy yarrrml #{o}  #{e}"
  o, e, _s = Open3.capture3("cp -rf ./SemanticModel/YARRRML/*.yaml  /data") # CDE V2
  warn "second open3 complete #{o} #{e}"
end

def yarrrml_substitute
  warn "starting yarrrml substitution"
  baseURI = ENV.fetch("baseURI", "http://example.org/")
  baseURI = "http://example.org/" if baseURI.empty?
  template_list = Dir["/conf/*.pre-yaml"]
  template_list.each do |t|
    content = File.read(t)
    content.gsub!("|||baseURI|||", baseURI)
    newfile = t.gsub!(".pre-yaml", "yaml")
    warn "writing #{newfile}"
    f = File.open(newfile, "w")
    f.puts content
    f.close
  end
  warn "finished yarrrml substitution"
end

def execute
  warn "executing transform"
  purge_nq
  @datatype_list = Dir["/data/*.csv"]
  @datatype_list.each do |d|
    datatype = d.match(%r{.+/([^.]+)\.csv})[1]
    next unless datatype

    _resp = RestClient.get("http://yarrrml-rdfizer:4567/#{datatype}")
  end
  warn "done transform"
end

def load_flair
  files = Dir["/data/triples/*.nq"]
  files.each do |f|
    warn "Processing file #{f}"
    datatype = d.match(%r{.+/([^.]+)\.nq})[1]
    content = File.read(f)
    content.gsub!(/\<\s+/, "<")
    write_to_graphdb(content, datatype)
    warn "wrote #{datatype}"
  end
end

def write_to_graphdb(concatenated, reponame)
  user = ENV.fetch("GraphDB_User", nil)
  pass = ENV.fetch("GraphDB_Pass", nil)
  network = ENV["networkname"] || "graphdb"
  #  reponame = ENV.fetch('GRAPHDB_REPONAME')
  url = "http://#{network}:7200/repositories/#{reponame}/statements"
  #  headers = { content_type: 'application/n-triples' }
  headers = { content_type: "application/n-quads" }
  HTTPUtils.put(url, headers, concatenated, user, pass)
end

def purge_nq
  File.delete("/data/triples/*.nq")
rescue StandardError
  warn "Deleting the exisiting .nq files failed!"
ensure
  warn "looks like it is already clean in here!"
end

def metadata_update
  return if ENV["DIST_RECORDID"].nil? || ENV["DATASET_RECORDID"].nil? || ENV["DATA_SPARQL_ENDPOINT"].nil?
  return if ENV["DIST_RECORDID"].empty? || ENV["DATASET_RECORDID"].empty? || ENV["DATA_SPARQL_ENDPOINT"].empty?

  warn "calling metadata updater image"
  begin
    resp = RestClient.get("http://updater:4567/update")
  rescue StandardError
    warn "\n\n\ncall to http://updater:4567/update FAILED"
    warn resp
  end
  warn "\n\nMetadata Update complete - look above for errors\n\n"
end

def cleanup
  warn "closing cleanup open3"
  _o, _s = Open3.capture2("rm -rf /data/triplesstats.csv")
end
