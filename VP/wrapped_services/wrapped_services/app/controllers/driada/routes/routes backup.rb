# # frozen_string_literal: false

# # def set_routes()

# DRIADA = "./app/controllers/driada/rawdata/out.csv".freeze

# get %r{/driada/?} do
#   # case type.to_s
#   # when "text/html"
#   redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface", 307
#   halt
#   # else
#   #   redirect "/wrapped-services/driada/interface/form"
#   #   halt
#   # end
# end

# get %r{/driada/lookup/?} do
#   unless params["species"]
#     # one day, solve this problem in the lighttpd proxy!  grrrrr
#     redirect "https://vp.bgv.cbgp.upm.es/wrapped-services/driada/interface/form", 307
#     halt
#   end

#   species = params["species"] ? params["species"].strip : ""
#   @species = species
#   @resp = species_lookup(species: species) # "./lib/vp"

#   request.accept.each do |type|
#     case type.to_s
#     when "text/html"
#       # need to set views for this wrapped service.  This may not be sustainable...
#       halt erb :driada_species
#     else
#       content_type :json
#       halt @resp.to_json
#     end
#   end
# end

# get %r{/driada/interface/form/?} do
#   # need to set views for this wrapped service.  This may not be sustainable...
#   halt erb :driada_lookupform
# end

# get %r{/driada/interface/?} do
#   redirect "https://wilkinsonlab.github.io/FLAIR-GG/VP/interfaces/wrapped_services.yaml", 307
# end
# # end
