module McpTools
  # [EXPERIMENTAL] MCP tool: runs a read-only SPARQL 1.1 SELECT query directly
  # against the FDP Index. Thin wrapper around {VP.execute_raw_sparql}, which
  # enforces the SELECT-only safety net (see +lib/common_queries.rb+).
  class SparqlQuery
    NAME = 'sparql_query'.freeze

    DESCRIPTION = <<~DESCRIPTION.freeze
      [EXPERIMENTAL] Executes a read-only SPARQL 1.1 SELECT query directly
      against the FDP Index, the same live network of FAIR Data Points that
      keyword_search searches. Use this for anything keyword_search can't
      answer - counting, grouping, filtering on dates or specific properties,
      or combining several conditions in one query. SELECT only: no ASK,
      CONSTRUCT, DESCRIBE, or updates. Results come back as JSON rows, one
      object per SPARQL result row, string-valued. A LIMIT is added
      automatically (default 100) if you don't include one.

      Key namespaces:
        PREFIX fdp: <https://w3id.org/fdp/fdp-o#>
        PREFIX ejp: <https://w3id.org/ejp-rd/vocabulary#>
        PREFIX dcat: <http://www.w3.org/ns/dcat#>
        PREFIX dcterms: <http://purl.org/dc/terms/>
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      A resource is publicly discoverable only if it has:
        ?resource ejp:vpConnection ejp:VPDiscoverable .

      Example 1 - list discoverable FAIR Data Points with their titles:
        PREFIX fdp: <https://w3id.org/fdp/fdp-o#>
        PREFIX ejp: <https://w3id.org/ejp-rd/vocabulary#>
        PREFIX dcterms: <http://purl.org/dc/terms/>
        SELECT ?resource ?title WHERE {
          ?resource a fdp:FAIRDataPoint ;
            dcterms:title ?title ;
            ejp:vpConnection ejp:VPDiscoverable .
        }

      Example 2 - keyword search over title/description/keyword fields:
        PREFIX dc: <http://purl.org/dc/terms/>
        PREFIX dcat: <http://www.w3.org/ns/dcat#>
        SELECT DISTINCT ?resource ?kw WHERE {
          VALUES ?searchfields { dc:title dc:description dc:keyword dcat:keyword }
          ?resource ?searchfields ?kw .
          FILTER(CONTAINS(LCASE(str(?kw)), LCASE("wheat")))
        }

      Example 3 - count data services of a given ontology type:
        PREFIX dcat: <http://www.w3.org/ns/dcat#>
        PREFIX dcterms: <http://purl.org/dc/terms/>
        SELECT (COUNT(?s) AS ?count) WHERE {
          ?s a dcat:DataService ;
            dcterms:type <http://edamontology.org/operation_3436> .
        }
    DESCRIPTION

    INPUT_SCHEMA = {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'A read-only SPARQL 1.1 SELECT query (see tool description for namespaces and examples)'
        }
      },
      required: ['query']
    }.freeze

    # Runs the tool.
    #
    # @param arguments [Hash] must contain a +query+ string
    # @return [Array<Hash>] MCP +content+ array, a single +text+ block
    #   whose text is the JSON-serialized array of result rows
    # @raise [ArgumentError, SPARQL::Client::ClientError, SPARQL::Client::ServerError]
    #   on a malformed, non-SELECT, or failing query - left to the caller
    #   (the MCP dispatcher) to turn into a JSON-RPC error
    def self.call(arguments)
      rows = VP.execute_raw_sparql(query: arguments['query'])
      [{ type: 'text', text: rows.to_json }]
    end
  end
end
