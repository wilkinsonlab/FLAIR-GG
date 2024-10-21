# frozen_string_literal: false

require_relative 'spec_helper'  # this will load the app

RSpec.describe 'ApplicationController', type: :request do
  include Rack::Test::Methods
  def app
    ApplicationController
  end

  it 'returns a list of all known resources' do
    get '/flair-gg-vp-server/resources'
    expect(last_response.status).to eq(406)
  end
end
