# frozen_string_literal: false

def set_routes()
  get "/diadra" do
    redirect "/diadra/interface"
  end

  get "/diadra/lookup" do

    unless params["species"]
      redirect "/diadra/interface/form"
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

  get "/diadra/interface/form" do
    halt erb :lookupform
  end

  get "/diadra/interface" do
    redirect "https://wilkinsonlab.github.io/FLAIR-GG/VP/interfaces/wrapped_services.yaml"
  end
end
