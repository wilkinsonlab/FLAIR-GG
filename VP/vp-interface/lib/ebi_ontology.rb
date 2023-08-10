class EBITerm
  attr_accessor :uri

  def initialize(uri:)
    @uri = uri
    @root = "https://www.ebi.ac.uk/ols4/api/ontologies/XXXXX/terms/"

    encoded = URI.encode_www_form_component uri
    encoded = URI.encode_www_form_component encoded

    if uri =~ /NCIT_/
      url = root.gsub("XXXXX", "ncit") + encoded
    elsif uri =~ /HP_/
      url = root.gsub("XXXXX", "hp") + encoded
    elsif uri =~ /GO_/
      url = root.gsub("XXXXX", "go") + encoded
    elsif uri =~ /SIO_/
      url = root.gsub("XXXXX", "sio") + encoded
    elsif uri =~ /UBERON_/
      url = root.gsub("XXXXX", "uberon") + encoded
    elsif uri =~ /ORDO/
      url = root.gsub("XXXXX", "ordo") + encoded
    elsif uri =~ /CMO_/
      url = root.gsub("XXXXX", "cmo") + encoded
    elsif uri =~ %r{ols/ontologies}
      url = uri.gsub("ols/ontologies", "ols/api/ontologies")
    end
  end

  def lookup(uri: self.uri)
    begin
      res = RestClient.get(uri)
    rescue StandardError
      warn "HTTP CALL FAILED FOR #{uri}"
      return nil
    end
    unless res
      warn "didn't resolve #{uri}"
      return nil
    end
    begin
      j = JSON.parse(res.body)
    rescue StandardError
      warn "parsing json body failed... likely an error"
      return nil
    end
    return nil unless j.is_a? Hash

    if j["_embedded"]
      warn "OLD STYLE OLS"
      warn "found word is #{j["_embedded"]["terms"][0]["label"]}"
      word = j["_embedded"]["terms"][0]["label"].to_s
    elsif j["label"]
      warn "NEW STYLE OLS"
      warn "found word is #{j["label"]}"
      word = j["label"].to_s
    elsif j["annotation"]
      warn "OTHER NEW STYLE OLS"
      warn "found word is #{j["annotation"]["label"]}"
      word = j["annotation"]["label"].to_s
    else
      warn "CAN'T UNDERSTAND RESPONSE BODY"
      return nil
    end
    warn "end of taxonomy parser"
    word
  end
end
