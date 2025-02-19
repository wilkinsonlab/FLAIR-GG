require "csv"
require "rest-client"
require 'securerandom'
require 'json'

def process_and_upload_output(results: )  # results[provider] = csv/json 

    key = SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"

    resp = RestClient::Request.execute(
        method: :put,
        url: "https://bgv.cbgp.upm.es/DAV/home/LDP/FLAIR/#{key}",
        content_type: :json,
        payload: results.to_json, 
        user: "ldp",
        password: "ldp"
    )
    warn resp.headers.inspect
    location = resp.headers[:location]  # where did it really put it?
    warn "LOCATION #{location}"
    return location
end
