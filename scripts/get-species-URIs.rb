require "json"
require "rest-client"
require "csv" # can't handle non-UTF8 characters

`echo "" > './output/not-found.txt'`
`echo "" > './output/multiple-found.txt'`
`echo "" > './output/species-taxid.csv'`

flag = 0
["./data/certainSpecies.csv", "./data/ambiguousSpecies.csv"].each do |file|
  CSV.foreach(file, headers: true, encoding: "ISO-8859-1") do |row|
#    CSV.foreach(file, headers: true, encoding: "UTF-8") do |row|
    species = ""
    original = ""
    species = row["canonicalName"]
    if row["Nombre original"]
      original = row["Nombre original"]
    end
    warn "getting #{species}"
    next unless species
    species.strip! 

    # use safe chaining
    unless species&.match(/\S\s\S/)
      File.open("not-found.txt", "a") { |f| f.puts original } 
      next
    end

    begin
      species = species.encode("UTF-8")
    rescue Encoding::UndefinedConversionError
      abort "this didn't work - bad encoding"
    end

    # deal with non-ASCII characters that come from stupid MS Windows
    species.gsub!(/[[:space:]]/, "%20")
    species.gsub!(/\P{ASCII}/, "")
    species.gsub!(/%20$/, "")
    warn "https://api.gbif.org/v1/species?name=#{species}"
    begin
      # this is just a cheap "try again" and isn't at all resilient, but surprisingly it catches almost all cases!
      results = RestClient.get("https://api.gbif.org/v1/species?name=#{species}")
    rescue StandardError
      results = RestClient.get("https://api.gbif.org/v1/species?name=#{species}")
    end

    parsed = JSON.parse(results)
    # warn parsed
    species.gsub!("%20", " ") # convert back from URL form

    unless parsed["results"].first
      warn "not found #{species}"
      File.open("not-found.txt", "a") { |f| f.puts species }
      next
    end

    thisresult = []
    parsed["results"].each do |result|
      next unless result["taxonomicStatus"] == "ACCEPTED"
      next unless result["taxonID"]&.match(/gbif:/) # if it doesnt' have a gbif taxon, ignore it

      thisresult << result
    end
    if thisresult.length > 1
      warn "multiple found #{species}"
      File.open("multiple-found.txt", "a") { |f| f.puts species }
      next
    elsif thisresult.length == 0
      warn "not found #{species}"
      File.open("not-found.txt", "a") { |f| f.puts species }
      next
    end
    accepted_result = thisresult.first
    gbif = accepted_result["taxonID"] # gbif:5370217
    # https://www.gbif.org/species/5370217
    gbif.gsub!("gbif:", "https://www.gbif.org/species/")
    File.open("./output/species-taxid.csv", "a") { |f| f.puts "#{species},#{gbif}" }
  end
end
