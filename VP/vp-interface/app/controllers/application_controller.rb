# frozen_string_literal: false

require_relative '../../config/environment' # for docker
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'erb'

# require 'omniauth'
# require 'omniauth-openid-connect'
require 'jwt'

# DO NOT change the order of loading below.  The files contain executable code that builds the overall configuration before this module starts
require_relative '../../lib/configuration' # VPConfig and FDPConfig
require_relative 'routes'
require_relative 'mcp_routes'
require_relative '../../lib/cache'
require_relative '../../lib/fdp'
require_relative '../../lib/vp'
require_relative '../../lib/metadata_functions'
require_relative '../../lib/services'
require_relative '../../lib/wordcloud'

# Top-level Sinatra application.  Inherits all HTTP routes from {VPRoutes} and
# performs VP initialisation. See +GET /flair-gg-vp-server+ (in routes.rb)
# for the OpenAPI document, generated from the request specs rather than
# configured here.
class ApplicationController < VPRoutes
  set :bind, '0.0.0.0'

  configure do
    enable :cross_origin
  end

  VP.new(config: VPConfig.new) # set up index and active sites
end
