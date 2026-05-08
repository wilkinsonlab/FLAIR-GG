# frozen_string_literal: false

require_relative '../../config/environment' # for docker
require 'swagger/blocks'
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'erb'

# require 'omniauth'
# require 'omniauth-openid-connect'
require 'jwt'

# DO NOT change the order of loading below.  The files contain executable code that builds the overall configuration before this module starts
require_relative '../../lib/configuration' # VPConfig and FDPConfig
require_relative 'models'
require_relative 'routes'
require_relative '../../lib/cache'
require_relative '../../lib/fdp'
require_relative '../../lib/vp'
require_relative '../../lib/metadata_functions'
require_relative '../../lib/services'
require_relative '../../lib/wordcloud'

# Top-level Sinatra application.  Inherits all HTTP routes from {VPRoutes} and
# adds Swagger/OpenAPI configuration and VP initialisation.
class ApplicationController < VPRoutes
  include Swagger::Blocks

  set :bind, '0.0.0.0'

  configure do
    enable :cross_origin
  end

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'FLAIR-GG Virtual Platform Server'
      key :description, 'Enables discovery of Germplasm resources'
      key :termsOfService, 'https://example.org'
      contact do
        key :name, 'Mark D. Wilkinson'
      end
      license do
        key :name, 'MIT'
      end
    end
    key :schemes, ['http']
    key :host, ENV.fetch('HARVESTER', nil)
    key :basePath, '/flair-gg-vp-server'
  end

  # All classes that carry +swagger_*+ declarations, used to build the OpenAPI
  # root document served by +GET /flair-gg-vp-server+.
  SWAGGERED_CLASSES = [ErrorModel, AllResourcesResponse, OntologySearchResponse, KeywordSearchResponse, self].freeze

  # @return [Array<Class>] the Swagger-annotated classes for this application
  def self.swaggered_classes
    SWAGGERED_CLASSES
  end

  VP.new(config: VPConfig.new) # set up index and active sites
end
