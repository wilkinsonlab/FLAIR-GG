class VPConfig
  FDPSITES = []
  FDPINDEX = ""

  def initialize(index: ENV["FDPINDEX"])
    abort "no FDP index provided" unless index =~ /^http/
    warn "running FDP Config"
    FDPINDEX.replace index

    index = index.gsub(%r{/\s*$}, "")
    indexapicall = "#{index}/index/entries/all"

    FDPSITES.replace get_active_sites(api: indexapicall)
  end

  def get_active_sites(api:)
    r = RestClient.get(api, headers: { accept: "application/json" })
    sites = JSON.parse(r.body).map { |s| s["clientUrl"] if s["state"] == "ACTIVE" }
    sites.compact!
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
  FDPDOMAIN = ""

  def initialize()
    # this is only used to create the prefix for the cache...
    FDPDOMAIN.replace VPConfig::FDPINDEX.gsub(%r{https?://}, "").gsub(%r{/.*}, "")
  end

end
