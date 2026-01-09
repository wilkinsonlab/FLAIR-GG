class VPConfig
  FDPSITES = []
  FDPINDEX = ''
  HOMEPAGE = ENV['HOMEPAGE'] || 'https://wilkinsonlab.github.io/FLAIR-GG/'
  ACKNOWLEDGEMENT = ENV['ACKNOWLEDGEMENT'] || 'Proyecto TED2021-130788B-I00 financiado por MCIN/AEI /10.13039/501100011033 y por la Unión Europea NextGeneration EU/PRTR'
  VPTITLE = ENV['VPTITLE'] || 'FLAIR-GG Virtual Platform'
  VPLOGO = ENV['VPLOGO'] || '/images/flair-gg-logo.png'

  def initialize(index: ENV['FDPINDEX'])
    abort 'no FDP index provided' unless index =~ /^http/
    warn 'running FDP Config'
    FDPINDEX.replace index

    index = index.gsub(%r{/\s*$}, '')
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

  def initialize
    # this is only used to create the prefix for the cache...
    FDPDOMAIN.replace VPConfig::FDPINDEX.gsub(%r{https?://}, '').gsub(%r{/.*}, '')
  end
end
