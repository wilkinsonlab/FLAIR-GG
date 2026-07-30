require_relative 'cache'

class Wordcloud
  attr_accessor :words

  def initialize(refresh: false)
    @words = []

    if File.exist?('./cache/keywords.json') && !refresh
      @words = thaw_keywords
    else
      begin
        f = open('./cache/WCREFRESHING', 'w') # multiple browser calls are a problem!
        f.puts 'WCREFRESHING'
        f.close
      rescue StandardError
        warn 'WCREfreshing file exists... continue'
      end

      @words << VP.current_vp.verbose_annotations
      warn 'flattening'
      @words = @words.flatten
      @words.compact!
      warn "\n\nWORDS\n\n#{@words}"
      freeze_keywords(words: @words)

      FileUtils.rm_f('./cache/WCREFRESHING')
    end
  end

  def self.refreshing?
    File.exist?('./cache/WCREFRESHING')
  end

  def count_words
    warn 'counting keywords'
    freqs = Hash.new(0)
    @words.each { |w| freqs[w] += 1 }
    warn freqs
    freqs
  end
end
