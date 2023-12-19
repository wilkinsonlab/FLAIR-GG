
require_relative "cache"

class Wordcloud
  attr_accessor :words

  def initialize(refresh: false)
    @words = []

    if File.exist?("./cache/keywords.json") && (refresh == "false")
      thaw_keywords
    else
      begin
        f = open("./cache/WCREFRESHING", "w")  # multiple browser calls are a problem!
        f.puts "WCREFRESHING"
        f.close
      rescue StandardError
        warn "WCREfreshing file exists... continue"
      end
      fdps = FDPConfig::FDPSITES
      @words = []
      fdps.each do |fdp|
        warn "\n\n\nQUERYING #{fdp}\n\n\n"
        site = FDP.new(address: fdp)
        @words << site.get_verbose_annotations
      end
      warn "flattening"
      @words = @words.flatten
      @words.compact!
      warn "\n\nWORDS\n\n#{@words}"
      freeze_keywords

      FileUtils.rm_f("./cache/WCREFRESHING")
    end
  end

  def count_words
    warn "counting keywords"
    freqs = {}
    @words.each do |w|
      freq = @words.count(w)
      freqs[w] = freq
    end
    warn freqs
    freqs
  end

end
