require "fileutils"

# class FDP
def thaw_fdp
  # address = Digest::SHA256.hexdigest @address
  # folder = getfolder
  # warn "thawing folder #{folder}"

  # begin
  #   warn "thawing file #{folder}/#{address}.ttl"
  #   RDF::Reader.open("#{folder}/#{address}.ttl") do |reader|
  #     reader.each_statement do |statement|
  #       @graph << statement
  #     end
  #   end
  # rescue StandardError
  #   nil
  # end
  # warn "graph #{@graph.size}"
end

def freeze_fdp
  # address = Digest::SHA256.hexdigest @address
  # folder = getfolder
  # f = open("#{folder}/#{address}.ttl", "w")
  # f.puts @graph.to_ttl
  # f.close
end

def thaw_keywords
  warn "thawing keyword cache"
  folder = getfolder
  kwf = File.open("#{folder}/keywords.json", "r")
  kw = kwf.read
  @words = JSON.parse(kw)
  warn "keyword cache thawed #{@words}"
rescue StandardError
  nil
end

def freeze_keywords
  warn "freezing keyword cache"
  folder = getfolder
  f = open("#{folder}/keywords.json", "w")
  f.puts @words.to_json
  f.close
end

def getfolder
  f = FDPConfig::FDPINDEX.gsub(%r{https?://}, "").gsub(%r{/.*}, "")
  FileUtils.mkdir_p "./cache/#{f}"
  "./cache/#{f}"
end
# end
