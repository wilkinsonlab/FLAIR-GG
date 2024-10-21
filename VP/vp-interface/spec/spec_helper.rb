ENV["SINATRA_ENV"] = "test"
ENV['RACK_ENV'] = "test"

require_relative '../config/environment'
require 'rspec'
require 'rack/test'
# require 'capybara/rspec'
# require 'capybara/dsl'


set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

module RSpecMixin
  def app
    ApplicationController

    # App.new
  end
end

RSpec.configure do |config|
  config.tty = true
  config.formatter = :documentation
  config.include Rack::Test::Methods
  config.include RSpecMixin
end
# RSpec.configure do |config|
#   config.run_all_when_everything_filtered = true
#   config.filter_run :focus
#   config.include Rack::Test::Methods
#   config.include Capybara::DSL
#   DatabaseCleaner.strategy = :truncation

#   config.before do
#     DatabaseCleaner.clean
#   end

#   config.after do
#     DatabaseCleaner.clean
#   end

#   config.order = 'default'
# end

def app
  Rack::Builder.parse_file('config.ru').first
end

# Capybara.app = app
