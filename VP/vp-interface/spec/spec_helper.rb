ENV['SINATRA_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

# Dummy config so VPConfig can boot without touching real infrastructure.
# Specs never talk to these hosts for real - see WebMock.disable_net_connect!
# below - they only exist so VPConfig's presence/format checks pass.
ENV['FDPINDEX'] ||= 'http://fdpindex.test'
ENV['FDPSPARQL'] ||= 'http://fdpindex.test/search/sparql'
ENV['FDPINDEX_API_TOKEN'] ||= 'test-token'

# `require 'webmock/rspec'` only *enables* WebMock's HTTP interception via an
# RSpec before(:each) hook, which hasn't fired yet at file-load time - but
# that's exactly when the app makes its one real HTTP call (see below). So
# enable WebMock manually first, stub the call, boot the app, and only then
# pull in the RSpec integration (for stub reset between examples).
require 'webmock'
WebMock.enable!
WebMock.disable_net_connect!

# ApplicationController's VP.new(config: VPConfig.new) runs a live "list
# active FDP sites" call the moment the app is loaded (VPConfig#initialize ->
# get_active_sites), so this has to be stubbed before requiring the app at all.
WebMock.stub_request(:get, "#{ENV['FDPINDEX']}/index/entries/all")
       .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })

require_relative '../config/environment'
require 'webmock/rspec'
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
  end

  # Builds an instance_double for VP, pre-stubbed with a working
  # #collect_data_services (called by VPRoutes' global `before` filter on
  # every request) plus any overrides the caller supplies, and installs it
  # as VP.current_vp for the current example.
  #
  # instance_double checks every stubbed method against VP's real method
  # signature, so a route calling a renamed/removed method fails the spec
  # immediately instead of silently passing - the exact class of bug that
  # slipped past manual testing into ServiceCollection#vpgraph=.
  def stub_vp(**overrides)
    vp = instance_double(VP, collect_data_services: [], **overrides)
    allow(VP).to receive(:current_vp).and_return(vp)
    vp
  end
end

RSpec.configure do |config|
  config.tty = true
  config.formatter = :documentation
  config.include Rack::Test::Methods
  config.include RSpecMixin
end
