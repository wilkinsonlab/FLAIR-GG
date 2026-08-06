require_relative 'raw_service_type_call'

module McpTools
  # MCP tool: raw IUCN endangerment-status data call, across every live
  # IUCN_categorization provider currently discoverable in the FLAIR-GG VP
  # network. The first instance of the {RawServiceTypeCall} pattern - one
  # tool per DCAT service type, each provider assumed to share the same
  # interface for a given +dc:type+, which is an unwritten FLAIR-GG
  # convention rather than something enforced in code.
  class IucnEndangermentStatus < RawServiceTypeCall
    NAME = 'iucn_endangerment_status'.freeze

    SERVICE_TYPE_URI = 'https://w3id.org/flair-gg-app/flair-gg-application-ontology.owl#IUCN_categorization'.freeze

    SUMMARY = <<~SUMMARY.freeze
      Executes the raw IUCN Red List endangerment-category lookup against
      every live IUCN_categorization data service currently discoverable in
      the FLAIR-GG VP network. Providers are found via the VP's own
      service-discovery search (not a hand-written SPARQL query), so newly
      added or relocated providers are picked up automatically.

      This is a fixed lookup - takes no parameters - each matching provider
      returns whatever IUCN-categorized records it currently has.

      Returns a JSON object keyed by provider endpoint URL. Each value is
      that provider's raw response body, or {"error": "..."} if that one
      provider failed to respond - other providers still return normally.
    SUMMARY

    DESCRIPTION = build_description(
      summary: SUMMARY,
      reference_notebook_filename: 'iucn_categorization.ipynb'
    ).freeze
  end
end
