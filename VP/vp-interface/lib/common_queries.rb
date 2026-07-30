class VP
  NAMESPACES = "
PREFIX fdp: <https://w3id.org/fdp/fdp-o#>
PREFIX ejp: <https://w3id.org/ejp-rd/vocabulary#>
PREFIX dcat: <http://www.w3.org/ns/dcat#>
PREFIX dc: <http://purl.org/dc/terms/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX ldp: <http://www.w3.org/ns/ldp#>
  PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
  ".freeze

  VPCONNECTION = 'ejp:vpConnection'.freeze
  VPDISCOVERABLE = 'ejp:VPDiscoverable'.freeze
  VPINVISIBLE = 'ejp:VPInvisible'.freeze
  VPANNOTATION = 'dcat:theme'.freeze

  # Builds a SPARQL::Client authenticated against the FDP Index's
  # +/search/sparql+ proxy (bearer token, see VPConfig::FDPINDEX_API_TOKEN).
  def self.sparql_client(endpoint:)
    FDPIndexClient.sparql_client(endpoint: endpoint, token: VPConfig::FDPINDEX_API_TOKEN)
  end

  # Escapes a value for safe interpolation inside a SPARQL string literal
  # ("..."), per the STRING_LITERAL_QUOTE production. Every user-supplied
  # value interpolated into a query as a quoted literal must go through this
  # - otherwise a value containing e.g. `"` can break out of the literal and
  # inject arbitrary SPARQL (this is exactly how SQL injection works, just
  # for SPARQL).
  def self.escape_sparql_literal(value)
    value.to_s.gsub('\\', '\\\\\\\\').gsub('"', '\\"').gsub("\n", '\\n').gsub("\r", '\\r')
  end

  # True if `value` contains none of the characters forbidden inside a
  # SPARQL IRIREF (<...>) - control characters, space, or < > " { } | ^ ` \.
  # There is no escape sequence for these inside an IRIREF, so a value that
  # fails this check cannot be safely interpolated there at all and must be
  # rejected rather than merely escaped.
  def self.safe_sparql_iri?(value)
    value.to_s.match?(/\A[^\x00-\x20<>"{}|^`\\]+\z/)
  end

  # [EXPERIMENTAL] Executes an arbitrary, LLM-authored read-only SPARQL query
  # against the FDP Index - see MCP_TOOLS in app/controllers/mcp_routes.rb
  # for the tool description/examples an LLM sees before calling this.
  #
  # Only SELECT is allowed (no ASK/CONSTRUCT/DESCRIBE/updates) - this is the
  # form whose results serialize simply and safely as JSON rows, and it's
  # the only one the FDP Index's own /search/sparql proxy needs to support
  # anyway (updates are rejected server-side regardless). A LIMIT is
  # appended automatically if the query doesn't include one, since an
  # LLM-authored query has no guarantee of being bounded and the index may
  # hold hundreds of entries.
  #
  # @param query [String] a SPARQL 1.1 SELECT query
  # @raise [ArgumentError] if the query is not a SELECT query
  # @return [Array<Hash>] one Hash per result row, variable name => string value
  def self.execute_raw_sparql(query:)
    normalized = query.to_s.strip
    unless normalized =~ /\A(?:PREFIX\s+\S*:\s*<[^>]*>\s*)*SELECT\b/i
      raise ArgumentError, 'Only SELECT queries are supported'
    end

    normalized = "#{normalized} LIMIT 100" unless normalized =~ /\bLIMIT\s+\d+\b/i

    sparql = sparql_client(endpoint: VPConfig::FDPSPARQL)
    sparql.query(normalized).map { |solution| solution.to_h.transform_values(&:to_s) }
  end

  def find_discoverables_query(endpoint:, keyword: nil, uri: nil)
    # try querying the FDP directly
    warn "querying endpoint #{endpoint}"
    sparql = VP.sparql_client(endpoint: endpoint)

    keyword_filter =
      if keyword
        "
          VALUES ?searchfields { dc:title dc:description dc:keyword dcat:keyword }
          ?resource ?searchfields ?kw .
          FILTER(CONTAINS(LCASE(str(?kw)), LCASE(\"#{VP.escape_sparql_literal(keyword)}\")))
        "
      else
        ''
      end

    uri_filter =
      if uri
        "
          ?resource dcat:theme ?theme .
          FILTER(CONTAINS(str(?theme), \"#{VP.escape_sparql_literal(uri)}\"))
        "
      else
        ''
      end

    vpd = <<DISCOVERY
    #{NAMESPACES}

    SELECT DISTINCT ?resource ?fdp ?resourceName ?resourceTypeURI ?ResourceType ?ServiceType ?resourceCreated ?resourceUpdated ?resourceHomepage ?resourceDescription ?resourceLogo ?publisherLogo

    WHERE {
        VALUES ?connection { ejp:vpConnection }
        VALUES ?discoverable { ejp:VPDiscoverable }
        VALUES ?invisible { ejp:VPInvisible }

        {  # top-level FDPs only

          BIND(fdp:FAIRDataPoint AS ?resourceTypeURI)

            ?resource a fdp:FAIRDataPoint ;
              dcterms:title ?resourceName .

              ?resource	?connection ?discoverable .

            # deal with dates, accepting both/either the fdp-ontology or the dcterms properties
            OPTIONAL { ?resource fdp:metadataIssued  ?fdpIssued . }
            OPTIONAL { ?resource dcterms:issued            ?dctIssued . }
            BIND(
                COALESCE(
                  ?fdpIssued,
                  ?dctIssued
                ) AS ?resourceCreated
              )
            OPTIONAL { ?resource fdp:metadataModified  ?fdpModified . }
            OPTIONAL { ?resource dcterms:modified      ?dctModified . }
            BIND(
                COALESCE(
                  ?fdpModified,
                  ?dctModified
                ) AS ?resourceUpdated
              )


            OPTIONAL { ?resource dcat:landingPage ?resourceHomePage }
            OPTIONAL { ?resource dcterms:description ?resourceDescription }
            OPTIONAL { ?resource foaf:logo ?resourceLogo }
            OPTIONAL { ?resource dcterms:publisher [ foaf:logo ?publisherLogo ] }
            OPTIONAL {
                      ?resource dcat:contactPoint ?c .
                      ?c vcard:hasURL ?url .
                      ?url vcard:url ?contact .
                    }

          BIND (
            REPLACE(
              REPLACE(
                IF(
                  CONTAINS(STRAFTER(str(?resource), "://"), "/"),
                  STRBEFORE(STRAFTER(str(?resource), "://"), "/"),
                  STRAFTER(str(?resource), "://")
                ),
                ":[0-9]+$", ""
              ),
              "/$", ""
            ) AS ?fdp
          )

          BIND (
            IF(
              CONTAINS(str(?resourceTypeURI), "#"),
              strafter(str(?resourceTypeURI), "#"),
              REPLACE(str(?resourceTypeURI), "^.*/", "")
            ) AS ?ResourceType
          )

          FILTER NOT EXISTS { ?s ?connection ?invisible }  # if they want to be invisible, remove them

      }

      UNION

      {  # everything that is a dcat:Resource, and a more specific type, but NOT an FDP

        # (note that VP resources must type themselves as dcat:Resource to be visible!!
        # this is pretty normal... FDP reference implementation does this, and so does Linked Data Platform.)
        ?resource a dcat:Resource ;
        a ?resourceTypeURI .
        # Exclude if ONLY typed as dcat:Resource
        FILTER EXISTS {
          ?resource a ?other .
          FILTER (?other != dcat:Resource)
        }

        ?resource	?connection ?discoverable .
        ?resource dcterms:title ?resourceName .

        # deal with dates, accepting both/either the fdp-o or the dcterms properties
        OPTIONAL { ?resource fdp:metadataIssued  ?fdpIssued . }
        OPTIONAL { ?resource dcterms:issued      ?dctIssued . }
        BIND(
          COALESCE(
            ?fdpIssued,
            ?dctIssued
          ) AS ?resourceCreated
        )
        OPTIONAL { ?resource fdp:metadataModified  ?fdpModified . }
        OPTIONAL { ?resource dcterms:modified            ?dctModified . }
        BIND(
          COALESCE(
            ?fdpModified,
            ?dctModified
          ) AS ?resourceUpdated
        )

        OPTIONAL { ?resource dcat:landingPage ?resourceHomePage }
        OPTIONAL { ?resource dcterms:type ?ServiceType . }
        OPTIONAL { ?resource dcterms:description ?resourceDescription }
        OPTIONAL { ?resource foaf:logo ?resourceLogo }
        OPTIONAL { ?resource dcterms:publisher [ foaf:logo ?publisherLogo ] }
        OPTIONAL {
                    ?resource dcat:contactPoint ?c .
                    ?c vcard:hasURL ?url .
                    ?url vcard:url ?contact .
                  }


        BIND (
          REPLACE(
            REPLACE(
              IF(
                CONTAINS(STRAFTER(str(?resource), "://"), "/"),
                STRBEFORE(STRAFTER(str(?resource), "://"), "/"),
                STRAFTER(str(?resource), "://")
              ),
              ":[0-9]+$", ""
            ),
            "/$", ""
          ) AS ?fdp
        )

        BIND (
          IF(
            CONTAINS(str(?resourceTypeURI), "#"),
            strafter(str(?resourceTypeURI), "#"),
            REPLACE(str(?resourceTypeURI), "^.*/", "")
          ) AS ?ResourceType
        )

        FILTER NOT EXISTS { ?s ?connection ?invisible }  # if the user wants to be invisible, remove them from the search results
        FILTER NOT EXISTS { ?resource a fdp:FAIRDataPoint }  # FDPs are often tagged as dataservices, which is a pain in the ass!

        FILTER( ?resourceTypeURI NOT IN (
          dcat:Resource,
          fdp:MetadataService,
          ldp:Container,
          ldp:BasicContainer
        # dcat:DataService
        ) )    #  We filter out data services here, only because the VP has a specific call for data services
        # FILTER CONTAINS(LCASE(str(?resourceDescription)), LCASE("proqolid"))
      }
      #{keyword_filter}
      #{uri_filter}
    }
    ORDER BY ?fdp
DISCOVERY

    # warn vpd.inspect
    # warn "\n\n", "QUERY #{vpd}", "\n\n"
    sparql.query(vpd)
  end

  def verbose_annotations_query(endpoint:)
    # TODO: This does not respect vpdiscoverable...
    sparql = VP.sparql_client(endpoint: endpoint)

    vpd = "
      #{NAMESPACES}
      SELECT DISTINCT ?annot WHERE
      { VALUES ?annotation { dcat:theme dcat:themeTaxonomy }
        ?s  ?annotation ?annot .
        }"
    sparql.query(vpd)
  end

  def keyword_annotations_query(endpoint:)
    sparql = VP.sparql_client(endpoint: endpoint)
    vpd = "
      #{NAMESPACES}
      select DISTINCT ?kw WHERE
      { VALUES ?searchfields { dc:keyword dcat:keyword }
      ?s ?searchfields ?kw .
      }"
    sparql.query(vpd)
  end

  def collect_data_services_query(endpoint:)
    sparql = VP.sparql_client(endpoint: endpoint)
    vpd = "

      #{NAMESPACES}

      SELECT DISTINCT ?type WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }

        ?s  ?connection ?discoverable ;
            a dcat:DataService .
            {
                ?s dcterms:type ?type .
            }
      }"

    # warn "\n\n\nSERVICES QUERY #{vpd}\n\n\n "
    sparql.query(vpd)
  end

  def self.collect_similar_services_query(endpoint:, termuri:)
    raise ArgumentError, "invalid service type URI: #{termuri.inspect}" unless safe_sparql_iri?(termuri)

    sparql = sparql_client(endpoint: endpoint)
    vpd = "
    #{NAMESPACES}
    SELECT DISTINCT ?contact ?title ?openapi ?endpoint WHERE
    {
      VALUES ?connection { #{VPCONNECTION} }
      VALUES ?discoverable { #{VPDISCOVERABLE} }

      ?s  ?connection ?discoverable ;
          a dcat:DataService ;
          dcterms:title ?title ;
          dcat:endpointURL ?endpoint ;
          dcat:endpointDescription ?openapi ;
          dcterms:type <#{termuri}> .
      OPTIONAL{?s dcat:contactPoint ?c .
        ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
    }"

    sparql.query(vpd)
  end
end
