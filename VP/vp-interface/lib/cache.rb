require "fileutils"

def thaw_keywords
  warn "thawing keyword cache"
  kwf = File.open("./cache/keywords.json", "r")
  kw = kwf.read
  kwf.close
  @words = JSON.parse(kw)
  warn "keyword cache thawed #{@words}"
  @words
end

def freeze_keywords
  warn "freezing keyword cache"
  f = open("./cache/keywords.json", "w")
  f.puts @words.to_json
  f.close
end


# deprecated
# def getfolder
#   f = FDPConfig::FDPINDEX.gsub(%r{https?://}, "").gsub(%r{/.*}, "")
#   FileUtils.mkdir_p "./cache/#{f}"
#   "./cache/#{f}"
# end
