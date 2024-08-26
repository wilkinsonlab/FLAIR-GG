class VP
  NAMESPACES = "PREFIX ejpold: <http://purl.org/ejp-rd/vocabulary/>
  PREFIX ejpnew: <https://w3id.org/ejp-rd/vocabulary#>
  PREFIX dcat: <http://www.w3.org/ns/dcat#>
  PREFIX dc: <http://purl.org/dc/terms/>
  ".freeze
  # VPCONNECTION = "ejpold:vpConnection ejpnew:vpConnection dcat:theme dcat:themeTaxonomy".freeze
  # VPDISCOVERABLE = "ejpold:VPDiscoverable ejpnew:VPDiscoverable".freeze
  # VPANNOTATION = "dcat:theme".freeze
  VPCONNECTION = "ejpnew:vpConnection".freeze
  VPDISCOVERABLE = "ejpnew:VPDiscoverable".freeze
  VPANNOTATION = "dcat:theme".freeze

    def find_discoverables_query(graph:)
      SPARQL.parse("
      #{NAMESPACES}
      SELECT DISTINCT ?s ?t ?title ?contact ?servicetype WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }

        ?s  ?connection ?discoverable ;
            dc:title ?title ;
            a ?t .

        OPTIONAL{?s dcat:contactPoint ?c .
                 ?c <http://www.w3.org/2006/vcard/ns#url> ?contact }.
        OPTIONAL{?s dc:type ?servicetype }.

      }
      ")
      graph.query(vpd)
    end

    def keyword_search_query(graph:, keyword:)
      vpd = SPARQL.parse("
      #{NAMESPACES}
  
      SELECT DISTINCT ?s ?t ?title ?contact WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }
        ?s  ?connection ?discoverable ;
            dc:title ?title ;
            a ?t .
        OPTIONAL{?s dcat:contactPoint ?c .
                 ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
            {
                VALUES ?searchfields { dc:title dc:description dc:keyword }
                ?s ?searchfields ?kw
                FILTER(CONTAINS(lcase(?kw), '#{keyword}'))
            }
      }")
      # warn "keyword search query #{vpd.to_sparql}"
      # warn "graph is #{@graph.size}"
      graph.query(vpd)

    end

    def ontology_search_query(graph:, uri:)
      vpd = SPARQL.parse("

      #{NAMESPACES}
  
      SELECT DISTINCT ?s ?t ?title ?contact WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }
  
        ?s  ?connection ?discoverable ;
            dc:title ?title ;
            a ?t .
        OPTIONAL{?s dcat:contactPoint ?c .
                 ?c <http://www.w3.org/2006/vcard/ns#url> ?contact } .
            {
                ?s dcat:theme ?theme .
                FILTER(CONTAINS(str(?theme), '#{uri}'))
            }
      }")
      
      graph.query(vpd)
    end

    def verbose_annotations_query(graph:)
      # TODO: This does not respect vpdiscoverable...
      vpd = SPARQL.parse("
      #{NAMESPACES}
      SELECT DISTINCT ?annot WHERE
      { VALUES ?annotation { dcat:theme dcat:themeTaxonomy }
        ?s  ?annotation ?annot .
        }")
      graph.query(vpd)
    end

    def keyword_annotations_query(graph:)
      vpd = SPARQL.parse("
      #{NAMESPACES}
      select DISTINCT ?kw WHERE
      { VALUES ?searchfields { dc:keyword }
      ?s ?searchfields ?kw .
      }")
      graph.query(vpd)
  
    end

    def collect_data_services_query(graph:)
      vpd = SPARQL.parse("

      #{NAMESPACES}

      SELECT DISTINCT ?type WHERE
      {
        VALUES ?connection { #{VPCONNECTION} }
        VALUES ?discoverable { #{VPDISCOVERABLE} }

        ?s  ?connection ?discoverable ;
            a dcat:DataService .
            {
                ?s dc:type ?type .
            }
      }")
      graph.query(vpd)
    end
    