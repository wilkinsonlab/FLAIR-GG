class FDPConfig
  FDPSITES = []
  FDPINDEX = ""
  FDPDOMAIN = ""
#  def initialize(index: "https://index.vp.ejprarediseases.org/")

  def initialize(index: ENV["FDPINDEX"])
    abort "no FDP index provided" unless index =~ /^http/
    warn "running FDP Config"
    FDPINDEX.replace index
    FDPDOMAIN.replace FDPConfig::FDPINDEX.gsub(%r{https?://}, "").gsub(%r{/.*}, "")

    index = index.gsub(%r{/\s*$}, "")
    index += "/index/entries/all"

    FDPSITES.replace get_active_sites(index: index)
    # %w[https://zks-docker.ukl.uni-freiburg.de/fairdatapoint-euronmd/ <https://fairdata.services:7070/
    #               <https://fair.ciroco.org <https://w3id.org/simpathic/fdp <https://w3id.org/fairvasc-fdp/ <https://w3id.org/ctsr-fdp <https://w3id.org/smartcare-fdp]
  end

  def get_active_sites(index:)
    r = RestClient.get(index, headers: { accept: "application/json" })
    # {
    #   "uuid": "48a1f752-8a60-4e40-a4bf-fc5e158f28f9",
    #   "clientUrl": "https://fdp.wikipathways.org/",
    #   "state": "ACTIVE",
    #   "registrationTime": "2023-07-04T14:36:52.885Z",
    #   "modificationTime": "2023-08-08T00:40:37.410Z"
    # },
    sites = JSON.parse(r.body).map { |s| s["clientUrl"] if s["state"] == "ACTIVE" }
    sites.compact!
    sites
  end
end
