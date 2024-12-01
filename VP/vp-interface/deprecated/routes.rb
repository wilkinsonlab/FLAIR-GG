require 'sinatra'
  
get %r{/test/?} do
  Sinatra::Base.set :views, File.dirname(__FILE__) + "/views"
  content_type :json
  '{"tewt": "boo"}'
end
get '/test/again' do
  set :views, File.dirname(__FILE__) + "/views2"

  content_type :json
  '{"tewt": "again"}'
end

