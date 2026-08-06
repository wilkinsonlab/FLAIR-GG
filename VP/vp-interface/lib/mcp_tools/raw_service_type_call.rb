module McpTools
  # Shared base for MCP tools that execute the "raw data call" - a plain GET
  # against every live endpoint of one DCAT service type, discovered through
  # the VP's own search API ({VP#retrieve_sevices}/{ServiceCollection}, the
  # same path backing the human-facing +/retrieve-services+ route) rather
  # than a hand-written SPARQL query - so as FDP providers come, go, or move
  # host (see the linkeddata.systems migration), the tool tracks them
  # automatically instead of drifting out of date.
  #
  # Deliberately does NOT go through {VP#execute_data_services_api}'s
  # LDP-upload/notebook wiring - that path exists to hand results to the
  # ComfyUI/Jupyter side via a temporary store, which an MCP caller has no
  # use for. This tool returns the raw provider responses directly in the
  # JSON-RPC result.
  #
  # A concrete tool subclasses this, defining +NAME+, +DESCRIPTION+, and
  # +SERVICE_TYPE_URI+ (the FDP service-type ontology URI to search for) -
  # +INPUT_SCHEMA+ and +call+ are inherited. This only fits service types
  # that take no parameters (a fixed lookup, like IUCN_categorization); a
  # future service type that takes real parameters needs its own +call+,
  # not this shared one.
  class RawServiceTypeCall
    INPUT_SCHEMA = { type: 'object', properties: {} }.freeze

    # Base URL under which FLAIR-GG-Analytics publishes its reference
    # Jupyter notebooks in raw, fetchable-as-JSON form - NOT the interactive
    # JupyterLite viewer {VP#notebook_url} builds for the human UI, which is
    # an HTML app, not something an LLM can read as content. A concrete
    # tool that has a corresponding notebook passes just the filename to
    # {.build_description}, rather than repeating this full path everywhere.
    REFERENCE_NOTEBOOK_BASE_URL =
      'https://raw.githubusercontent.com/wilkinsonlab/FLAIR-GG-Analytics/main/content/FLAIR-GG/'.freeze

    REFERENCE_NOTEBOOK_HINT = <<~HINT.freeze
      Reference implementation: %<url>s - the Jupyter notebook this data is
      normally analyzed in. If you can fetch web content, read it for
      guidance on how this kind of data is typically processed, categorized,
      or plotted - this tool itself returns only the raw provider data, not
      notebook content.
    HINT

    # Builds a tool's +DESCRIPTION+: the given summary, plus
    # {REFERENCE_NOTEBOOK_HINT} pointing at +reference_notebook_filename+'s
    # raw URL, if given. Most tools built on this base correspond to exactly
    # one FLAIR-GG-Analytics notebook, so a subclass should normally pass
    # one - this is the default shape, not a rarely-used extra.
    #
    # @param summary [String] the tool-specific description text
    # @param reference_notebook_filename [String, nil] e.g.
    #   <tt>'iucn_categorization.ipynb'</tt> - omit only for a tool with no
    #   corresponding notebook
    # @return [String] the composed description
    def self.build_description(summary:, reference_notebook_filename: nil)
      return summary.strip unless reference_notebook_filename

      url = REFERENCE_NOTEBOOK_BASE_URL + reference_notebook_filename
      "#{summary.strip}\n\n#{format(REFERENCE_NOTEBOOK_HINT, url: url).strip}"
    end

    # Runs the tool: discovers every live endpoint implementing
    # +self::SERVICE_TYPE_URI+ and executes a raw GET against each.
    #
    # @param _arguments [Hash] unused - these services take no parameters
    # @return [Array<Hash>] MCP +content+ array, a single +text+ block whose
    #   text is a JSON object keyed by endpoint URL. Each value is either the
    #   raw response body, or +{"error": "..."}+ if that one endpoint failed -
    #   one dead/migrating provider must not sink the whole call.
    def self.call(_arguments)
      servicecollection, = VP.current_vp.retrieve_sevices(termuri: self::SERVICE_TYPE_URI)
      accept = VP.current_vp.guess_best_content_type(termuri: self::SERVICE_TYPE_URI)

      results = {}
      servicecollection.allservices.each do |service|
        results[service.endpoint] = fetch_raw(service: service, accept: accept)
      end
      [{ type: 'text', text: results.to_json }]
    end

    def self.fetch_raw(service:, accept:)
      response = Service.execute_get(endpoint: service.endpoint, params: {}, accept: accept)
      return { error: 'Request failed - no response' } unless response

      response.body
    rescue StandardError => e
      { error: e.message }
    end
    private_class_method :fetch_raw
  end
end
