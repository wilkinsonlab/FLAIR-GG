# frozen_string_literal: false

DRIADA = "./app/controllers/driada/rawdata/out.csv".freeze

get %r{/driada/?} do
  redirect "/driada/interface", 303
  halt
end

get %r{/driada/lookup/?} do
  Sinatra::Base.set :views, "./app/controllers/driada/views"
  unless params["species"]
    redirect "/driada/interface/form", 303
    halt
  end

  species = params["species"] ? params["species"].strip : ""
  @species = species
  @resp = species_lookup(species: species) # "./lib/vp"

  request.accept.each do |type|
    case type.to_s
    when "text/html"
      halt erb :species
    else
      content_type :json
      halt @resp.to_json
    end
  end
end

get %r{/driada/interface/form/?} do
  Sinatra::Base.set :views, "./app/controllers/driada/views"
  halt erb :lookupform
end

get %r{/driada/interface/?} do
  halt erb :interface
end
# end
