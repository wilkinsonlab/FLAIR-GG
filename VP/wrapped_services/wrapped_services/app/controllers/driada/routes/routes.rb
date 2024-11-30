# frozen_string_literal: false

# def set_routes()


  DRIADA = "./app/controllers/driada/rawdata/out.csv".freeze

  get "/driada" do
    # case type.to_s
    # when "text/html"
      redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface"
      halt
    # else
    #   redirect "/wrapped-services/driada/interface/form"
    #   halt
    # end
  end

  get "/driada/" do
    # case type.to_s
    # when "text/html"
      redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface"
      halt
    # else
    #   redirect "/wrapped-services/driada/interface/form"
    #   halt
    # end
  end

  get "/driada/lookup" do
    unless params["species"]
      # one day, solve this problem in the lighttpd proxy!  grrrrr
      redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface/form"
      halt
    end

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
  get "/driada/lookup/" do
    unless params["species"]
      # one day, solve this problem in the lighttpd proxy!  grrrrr
      redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface/form"
      halt
    end

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

  get "/driada/interface/form" do
    # need to set views for this wrapped service.  This may not be sustainable...
    halt erb :driada_lookupform
  end
  get "/driada/interface/form/" do
    # need to set views for this wrapped service.  This may not be sustainable...
    halt erb :driada_lookupform
  end

  get "/driada/interface" do
    redirect "https://wilkinsonlab.github.io/FLAIR-GG/VP/interfaces/wrapped_services.yaml"
  end
# end
