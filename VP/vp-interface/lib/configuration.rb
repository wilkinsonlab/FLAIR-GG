# frozen_string_literal: false

class VPConfig
  fdpindex = ENV['FDPINDEX']
  fdpindex = fdpindex.dup
  fdpindex.gsub!(%r{/\s*$}, '') # no diference between http://my.org/  and http://my.org
  FDPINDEX = fdpindex.freeze

  fdpsparql = ENV['FDPSPARQL']
  fdpsparql = fdpsparql.dup
  fdpsparql.gsub!(%r{/\s*$}, '') # no diference between http://my.org/  and http://my.org
  FDPSPARQL = fdpsparql.freeze

  FDPINDEX_API_TOKEN = ENV['FDPINDEX_API_TOKEN'].freeze

  FDPSITES = []
  HOMEPAGE = ENV['HOMEPAGE'] || 'https://wilkinsonlab.github.io/FLAIR-GG/'
  ACKNOWLEDGEMENT = ENV['ACKNOWLEDGEMENT'] || 'Proyecto TED2021-130788B-I00 financiado por MCIN/AEI /10.13039/501100011033 y por la Unión Europea NextGeneration EU/PRTR'
  VPTITLE = ENV['VPTITLE'] || 'FLAIR-GG Virtual Platform'
  VPLOGO = ENV['VPLOGO'] || '/images/flair-gg-logo.png'

  def initialize(index: FDPINDEX, sparql: FDPSPARQL)
    abort 'no FDP index provided' unless index =~ /^http/
    abort 'no FDP sparql provided' unless sparql =~ /^http/
    abort 'no FDP index API token provided (FDPINDEX_API_TOKEN)' if FDPINDEX_API_TOKEN.nil? || FDPINDEX_API_TOKEN.empty?
    warn 'running FDP Config'

    indexapicall = "#{index}/index/entries/all"

    FDPSITES.replace get_active_sites(api: indexapicall)
  end

  def get_active_sites(api:)
    warn "getting from index #{api}"
    r =  RestClient::Request.execute(
      url: api,
      method: :get,
      headers: { accept: 'application/json' },
      verify_ssl: false
    )
    sites = JSON.parse(r.body).map { |s| s['clientUrl'] if ['ACTIVE'].include? s['state'] }
    sites.compact!
    warn "FOUND SITES #{sites}"
    sites
  end
  # {
  #   "uuid": "48a1f752-8a60-4e40-a4bf-fc5e158f28f9",
  #   "clientUrl": "https://fdp.wikipathways.org/",
  #   "state": "ACTIVE",
  #   "registrationTime": "2023-07-04T14:36:52.885Z",
  #   "modificationTime": "2023-08-08T00:40:37.410Z"
  # },
end

class FDPConfig
  FDPDOMAIN = ''
  FDPINDEX = VPConfig::FDPINDEX
  FDPSPARQL = VPConfig::FDPSPARQL

  def initialize
    # this is only used to create the prefix for the cache...
    FDPDOMAIN.replace FDPINDEX.gsub(%r{https?://}, '').gsub(%r{/.*}, '')
  end
end
