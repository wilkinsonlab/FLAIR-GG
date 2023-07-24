require "./scripts/fdp"

# frozen_string_literal: false
# warn `pwd`
# abort

fdps = %w[https://zks-docker.ukl.uni-freiburg.de/fairdatapoint-euronmd/ https://fairdata.services:7070/]

fdps.each do |fdp_address|
  fdp = FDP.new(address: fdp_address)
  puts fdp
  puts fdp.find_discoverables
end
