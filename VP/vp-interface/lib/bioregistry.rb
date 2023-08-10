
class BioRegistry

    attr_accessor :uri

    def initialize(uri:)
      @uri = uri
    end

    def lookup(uri: self.uri)
      # e.g. http://bioregistry.io/edam:data_1153
      # https://bioregistry.io/api/reference/orphanet.ordo:83419
      # {
      #   "query": {
      #     "prefix": "ncit",
      #     "identifier": "C28421"
      #   },
      #   "providers": {
      #     "default": "http://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI%20Thesaurus&code=C28421",
      #     "bioregistry": "https://bioregistry.io/ncit:C28421",
      #     "miriam": "https://identifiers.org/ncit:C28421",
      #     "obofoundry": "http://purl.obolibrary.org/obo/NCIT_C28421",
      #     "ols": "https://www.ebi.ac.uk/ols4/ontologies/ncit/terms?iri=http://purl.obolibrary.org/obo/NCIT_C28421",
      #     "n2t": "https://n2t.net/ncit:C28421",
      #     "bioportal": "https://bioportal.bioontology.org/ontologies/NCIT/?p=classes&conceptid=http://purl.obolibrary.org/obo/NCIT_C28421",
      #     "bio2rdf": "http://bio2rdf.org/ncit:C28421",
      #     "evs": "http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#C28421"
      #   }
      # }# }
      term = uri.match(%r{.*/(\S+?)$})[1] # edam:data_1153
      bioreg = "https://bioregistry.io/api/reference/#{term}"
      warn "BIOREG #{bioreg}"
      resp = nil
      begin
        resp = RestClient.get(bioreg)
      rescue StandardError
        warn "\t\t\t\t\tRESCUING!!!!!!!!!!!!!!!!!!!!!!!!!"
        resp = nil
      end
      unless resp
        warn "NOTHING FOUND IN BIOREG"
        return nil
      end
      warn "BIOREG RESPONDED"
      j = JSON.parse(resp.body)
      url = j["providers"]["obofoundry"] || j["providers"]["default"]
      warn "DEFAULT provider #{url}"
      url
    end
  end
