# Objective:
# dcat:theme <http://purl.org/ejp-rd/vocabulary/VPDiscoverable>, <http://semanticscience.org/resource/SIO_000614> ;
#
# dcat:keyword "Becker Muscular Dystrophy", "Clinical data", "Duchenne Muscular Dystrophy", "Genetic data", "PROMs", "PROs";

require 'csv'

theme = "dcat:theme "
keywords = "dcat:keyword "
CSV.foreach("./output/species-taxid2.csv") do |line|
    kw = line[0]
    tid = line[1]
    next unless kw && tid
    theme += "<#{tid}>, "
    keywords += "\"#{kw}\", "
end

theme.gsub!(/\,\s+$/, "")
keywords.gsub!(/\,\s+$/, "")
theme += " ;"
keywords += " ;"

puts theme
puts; puts; puts
puts keywords
