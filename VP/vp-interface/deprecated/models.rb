class ErrorModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :ErrorModel do
    key :required, %i[code message]
    property :code do
      key :type, :integer
      key :format, :int32
    end
    property :message do
      key :type, :string
    end
  end
end

# class InputScheme # Notice, this is just a plain ruby object.
#   include Swagger::Blocks

#   swagger_schema :InputScheme do
#     key :required, %i[guid]
#     property :guid do
#       key :type, :string
#     end
#   end
# end

class LinksResponse
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/links' do
    operation :get do
      key :summary, 'retrieve links'
      key :description, 'retrieve the link headers discovered (as HTML link headers)'
      key :operationId, 'links_retrieve'
      key :tags, ['retrieve_links']
      key :produces, [
        'text/html'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'discovered links'
      end
    end
  end
end

class LinkedDataResponse
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/ld' do
    operation :get do
      key :summary, 'retrieve graph metadata'
      key :description, 'retrieve the linked-data metadata gathered by following the "described-by" link headers, as json-ld'
      key :operationId, 'graph_retrieve'
      key :tags, ['retrieve_rdf']
      key :produces, [
        'application/ld+json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'discovered graph metadata'
      end
    end
  end
end

class LinkedDataResponseNegotiation
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/ld-by-old-workflow' do
    operation :get do
      key :summary, 'retrieve graph metadata using full Champion harvesting workflow'
      key :description,
          'retrieve the linked-data metadata gathered obtained by the full harvesting workflow used by The Champion combined with the FAIR Signposing'
      key :operationId, 'graph_retrieve_evaluator'
      key :tags, ['retrieve_rdf_champion_workflow']
      key :produces, [
        'application/ld+json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'discovered graph metadata'
      end
    end
  end
end

class JSONDataResponseNegotiation
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/json-by-old-workflow' do
    operation :get do
      key :summary, 'retrieve hash-style metadata using full Champion harvesting workflow'
      key :description,
          'retrieve the non-linked-data metadata gathered obtained by the full harvesting workflow used by The Champion combined with the FAIR Signposing'
      key :operationId, 'json_retrieve_evaluator'
      key :tags, ['retrieve_json_champion_workflow']
      key :produces, [
        'application/json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'discovered graph metadata'
      end
    end
  end
end


class JSONResponse
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/json' do
    operation :get do
      key :summary, 'retrieve non-graph metadata'
      key :description,
          'retrieve the non-linked-data metadata gathered by following the "described-by" link headers, as JSON'
      key :operationId, 'json_retrieve'
      key :tags, ['retrieve_json']
      key :produces, [
        'application/json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'discovered structured metadata'
      end
    end
  end
end

class JSONWarnings
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/warnings' do
    operation :get do
      key :summary, 'retrieve warnings'
      key :description,
          'retrieve warnings generated during metadata gathering'
      key :operationId, 'warnings'
      key :tags, ['warnings']
      key :produces, [
        'application/json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'generated warnings'
      end
    end
  end
end

class JSONWarningsFull
  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_path '/champion-warnings' do
    operation :get do
      key :summary, 'retrieve warnings'
      key :description,
          'retrieve warnings generated during metadata gathering using full Champion workflow'
      key :operationId, 'champion-warnings'
      key :tags, ['champion warnings']
      key :produces, [
        'application/json'
      ]
      parameter do
        key :name, :guid
        key :in, :query
        key :description, 'GUID to process'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'generated warnings'
      end
    end
  end
end
