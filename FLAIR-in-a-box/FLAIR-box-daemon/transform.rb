require "sinatra"
require "rest-client"
require "./http_utils"
require "open3"

include HTTPUtils

# Version 0.0.6
get "/" do
  update_yarrrml
  update_csv
  yarrrml_substitute
  execute
  load_flair
  cleanup
  # metadata_update
  "Execution complete.  See docker log for errors (if any)\n\n"
end

def update_yarrml
  warn "first open3 git pull"
  o, e, _s = Open3.capture3("cd FLAIR-GG && git pull")
  warn "second open3 copy yarrrml #{o}  #{e}"
  o, e, _s = Open3.capture3("cp -rf ./FLAIR-GG/SemanticModel/YARRRML/*.pre-yaml  /data") # CDE V2
  warn "second open3 complete #{o} #{e}"
end

def update_csv
  datatypes = {
    admin: ENV["ADMIN_SHEET" ],
    germplasm: ENV["GERMPLASM_SHEET"],
    location: ENV["LOCATION_SHEET"]
  }

  datatypes.each do |datatype, sheet|
    next if sheet.empty

    # Transform the spreadsheet URL to CSV export format
    csv_url = sheet.sub(%r{/edit.*$}, "") + "/export?exportFormat=csv"
    # Use RestClient with follow redirects (default max_redirects is 10)
    response = RestClient::Request.execute(
      method: :get,
      url: csv_url,
      headers: { accept: "text/csv" },
      max_redirects: 10
    )
    csv = response.body
    File.open("/data/#{datatype}.csv", "w") do |file|
      file.write csv, "\n"
    end
  end
end

def yarrrml_substitute
  warn "starting yarrrml template template substitution"
  base_uri = ENV.fetch("baseURI", "http://example.org/")
  base_uri = "http://example.org/" if base_uri.empty?
  template_list = Dir["/data/*.pre-yaml"]
  template_list.each do |t|
    content = File.read(t)
    content.gsub!("|||baseURI|||", base_uri)
    newfile = t.gsub(".pre-yaml", ".yaml")
    warn "writing #{newfile}"
    # warn "writing content #{content}"
    File.write(newfile, content)
    warn "deleting #{t}"
    File.delete(t)
    warn "deleted #{t}"
  end
  warn "finished yarrrml template template substitution"
end

def execute
  warn "executing transform"
  #  purge_nq
  purge_ttl
  @datatype_list = Dir["/data/*.csv"]
  @datatype_list.each do |d|
    datatype = d.match(%r{.+/([^.]+)\.csv})[1]
    next unless datatype

    warn "starting transform of #{datatype}: http://yarrrml-rdfizer:4567/#{datatype}"
    _resp = RestClient.get("http://yarrrml-rdfizer:4567/#{datatype}")
    warn "completed transform of #{datatype}: http://yarrrml-rdfizer:4567/#{datatype}"
  end
end

def load_flair
  files = Dir["/data/triples/*.ttl"]
  files.each do |f|
    warn "Processing file #{f}"
    datatype = f.match(%r{.+/([^.]+)\.ttl})[1]
    content = File.read(f)
    content.gsub!(/<\s+/, "<")
    write_to_graphdb(content, datatype)
    warn "wrote #{datatype}"
  end
end

def write_to_graphdb(concatenated, reponame)
  user = ENV.fetch("GraphDB_User", nil)
  pass = ENV.fetch("GraphDB_Pass", nil)
  network = ENV["networkname"] || "graphdb"
  url = "http://#{network}:7200/repositories/#{reponame}/statements"
  #  headers = { content_type: "application/n-quads" }
  headers = { content_type: "text/turtle" }
  HTTPUtils.put(url, headers, concatenated, user, pass)
end

def purge_nq
  `rm -rf /data/triples/*.nq`
rescue StandardError
  warn "Deleting the exisiting .nq files failed!"
ensure
  warn "looks like it is already clean in here!"
end

def purge_ttl
  `rm -rf /data/triples/*.ttl`
rescue StandardError
  warn "Deleting the exisiting .nq files failed!"
ensure
  warn "looks like it is already clean in here!"
end

# DEPRECATED
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
