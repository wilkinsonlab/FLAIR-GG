# frozen_string_literal: false

require "sinatra"
require "sinatra/base"
require "json"
require "erb"
require "csv"
require_relative "../../lib/lookups" 
require_relative "./routes" 

#DIADRA = "./diadra/app/rawdata/BD_Driada20240825.csv".freeze
warn `pwd`
DIADRA = "./app/rawdata/out.csv".freeze

configure do
  set :public_folder, "public"
  set :views, "app/views"
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

set_routes

# run! if app_file == $PROGRAM_NAME
