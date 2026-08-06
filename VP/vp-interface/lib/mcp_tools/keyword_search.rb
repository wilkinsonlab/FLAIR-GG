module McpTools
  # MCP tool: searches the FLAIR-GG VP network for resources whose metadata
  # contains a given keyword. Thin wrapper around {VP#keyword_search_shell},
  # the same method backing the human-facing +/keyword-search+ route.
  class KeywordSearch
    NAME = 'keyword_search'.freeze

    DESCRIPTION = 'Searches the FLAIR-GG VP network for resources whose metadata ' \
                  'contains the given keyword. Case-insensitive. Returns basic ' \
                  'resource info only (no contact/curator details) - for "who do I ' \
                  'contact" questions or anything else beyond a simple keyword match, ' \
                  'use sparql_query instead.'.freeze

    INPUT_SCHEMA = {
      type: 'object',
      properties: {
        keyword: {
          type: 'string',
          description: 'The term to search for'
        }
      },
      required: ['keyword']
    }.freeze

    # Runs the tool.
    #
    # @param arguments [Hash] must contain a +keyword+ string
    # @return [Array<Hash>] MCP +content+ array, a single +text+ block
    #   whose text is the JSON-serialized array of matching {Discoverable}s
    def self.call(arguments)
      keyword = arguments['keyword'] ? arguments['keyword'].strip : ''
      discoverables = VP.current_vp.keyword_search_shell(keyword: keyword)
      [{ type: 'text', text: discoverables.to_json }]
    end
  end
end
