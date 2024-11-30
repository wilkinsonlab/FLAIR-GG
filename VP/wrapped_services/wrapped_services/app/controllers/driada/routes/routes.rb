# frozen_string_literal: false

# def set_routes()


  DRIADA = "./app/controllers/driada/rawdata/out.csv".freeze

  get "/wrapped-services/driada" do
    redirect "/wrapped-services/driada/interface"
  end

  get "/wrapped-services/driada/lookup" do
    unless params["species"]
      redirect "/wrapped-services/driada/interface/form"
      halt
    end
warn "PWD", `pwd`
    species = params["species"] ? params["species"].strip : ""
    @species = species
    @resp = species_lookup(species: species) # "./lib/vp"

    request.accept.each do |type|
      case type.to_s
      when "text/html"
        # need to set views for this wrapped service.  This may not be sustainable...
        halt erb :driada_species
      else
        content_type :json
        halt @resp.to_json
      end
    end
  end

  get "/wrapped-services/driada/interface/form" do
    # need to set views for this wrapped service.  This may not be sustainable...
    halt erb :driada_lookupform
  end

  get "/wrapped-services/driada/interface" do
    redirect "https://wilkinsonlab.github.io/FLAIR-GG/VP/interfaces/wrapped_services.yaml"
  end
# end
