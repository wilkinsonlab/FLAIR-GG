/class IDsOrg
  attr_accessor :uri
  def initialize(uri:)
    @uri = uri
    return nil unless @uri =~ /\/identifiers\.org\//
    # https://resolver.api.identifiers.org/orphanet:183

  end


end
