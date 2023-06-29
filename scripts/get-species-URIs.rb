require 'json'
require 'rest-client'
require 'csv' # can't handle non-UTF8 characters

`echo "" > 'not-found.txt'`
`echo "" > 'multiple-found.txt'`
`echo "" > './output/species-taxid2.csv'`

flag = 0
CSV.foreach('./data/species-from-alberto2.csv', headers: false, encoding: 'UTF-8') do |row|
  #  species = row['Nombre aceptado']
  species = row[0]
  next unless species
  species.strip!
  next unless species
  next unless species =~ /\s/ # must be binomial scientific name

  next if species.empty?

  begin
    species = species.encode('UTF-8')
  rescue Encoding::UndefinedConversionError
    abort "this didn't work - bad encoding"
  end


  # deal with non-ASCII characters that come from stupid MS Windows
  species.gsub!(/[[:space:]]/, '%20')
  species.gsub!(/\P{ASCII}/, '')
  species.gsub!(/%20$/, '')
  warn "https://api.gbif.org/v1/species?name=#{species}"
  begin
    results = RestClient.get("https://api.gbif.org/v1/species?name=#{species}")
  rescue
    results = RestClient.get("https://api.gbif.org/v1/species?name=#{species}")
  end

  parsed = JSON.parse(results)
  # warn parsed
  species.gsub! /%20/, " "  # convert back from URL form

  unless parsed['results'].first
    warn "not found #{species}"
    File.open('not-found.txt', 'a') { |f| f.puts species }
    next
  end

  thisresult = []
  parsed['results'].each do |result|
    next unless result['taxonomicStatus'] = 'ACCEPTED'
    next unless result['taxonID']&.match(/gbif:/)  # if it doesnt' have a gbif taxon, ignore it

    thisresult << result
  end
  if thisresult.length > 1
    warn "multiple found #{species}"
    File.open('multiple-found.txt', 'a') { |f| f.puts species }
  end
  accepted_result = thisresult.first
  gbif = accepted_result['taxonID'] # gbif:5370217
  # https://www.gbif.org/species/5370217
  gbif.gsub!(/gbif:/, 'https://www.gbif.org/species/')
  File.open('./output/species-taxid2.csv', 'a') { |f| f.puts "#{species},#{gbif}" }
end
