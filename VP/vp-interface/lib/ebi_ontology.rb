class EBITerm
  attr_accessor :uri
  attr_accessor :synonym_urls

  def initialize(uri:)
    @uri = uri
    @synonym_urls = []
    root = "https://www.ebi.ac.uk/ols4/api/ontologies/XXXXX/terms/"

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
    @synonym_urls << url
  end

  def lookup_title(synonym_urls: @synonym_urls)
    title = nil
    synonym_urls.each do |uri|
      begin
        res = RestClient.get(uri)
      rescue StandardError
        warn "HTTP CALL FAILED FOR #{uri}"
      end
      unless res
        warn "didn't resolve #{uri}"
      end
      begin
        j = JSON.parse(res.body)
      rescue StandardError
        warn "parsing json body failed... likely an error"
      end
      return title unless j.is_a? Hash

      if j["_embedded"]
        warn "OLD STYLE OLS"
        warn "found word is #{j["_embedded"]["terms"][0]["label"]}"
        title = j["_embedded"]["terms"][0]["label"].to_s
      elsif j["label"]
        warn "NEW STYLE OLS"
        warn "found word is #{j["label"]}"
        title = j["label"].to_s
      elsif j["annotation"]
        warn "OTHER NEW STYLE OLS"
        warn "found word is #{j["annotation"]["label"]}"
        title = j["annotation"]["label"].to_s
      else
        warn "CAN'T UNDERSTAND RESPONSE BODY"
      end
      warn "end of taxonomy parser"
    end
    title
  end
end
