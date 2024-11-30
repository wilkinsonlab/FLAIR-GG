# frozen_string_literal: false

require "sinatra"
require "sinatra/base"
require "json"
require "erb"
require "csv"
require "require_all"
require_all "."

warn `pwd`

configure do
  set :public_folder, "public"
  set :views, "app/controllers/views/"
  set :bind, "0.0.0.0"
  set :server_settings, timeout: 180

  before do
    response.headers["Access-Control-Allow-Origin"] = "*"
  end
  enable :cross_origin
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

# set_routes
