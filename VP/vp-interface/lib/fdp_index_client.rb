require 'sparql/client'

# Thin client for the FAIR Data Point (FDP) Index reference implementation's
# bearer-token-authenticated endpoints (https://github.com/FAIRDataTeam/FAIRDataPoint).
#
# Deliberately has no dependency on VP/Discoverable/FLAIR-GG-specific models —
# everything here is generic to any project talking to an FDP Index, and is a
# reasonable candidate to split out into its own gem if a second consumer
# shows up.
module FDPIndexClient
  # Builds a SPARQL::Client authenticated against an FDP Index's
  # +/search/sparql+ SPARQL-protocol proxy.
  #
  # @param endpoint [String] the +/search/sparql+ URL
  # @param token [String] bearer token (see the Index's +/tokens+ or +/api-keys+ endpoints)
  # @return [SPARQL::Client]
  def self.sparql_client(endpoint:, token:)
    SPARQL::Client.new(
      endpoint,
      method: :post,
      headers: {
        accept: 'application/sparql-results+json',
        authorization: "Bearer #{token}"
      }
    )
  end
end
