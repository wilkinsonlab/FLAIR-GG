require "csv"
require "rest-client"
require 'securerandom'
require 'json'

def process_and_upload_sparql_output(results: )  # results[provuder] = csv

    # outputs are csv headers plus csv
    # in principole, all headers shold be identical
    # strip_converter = proc {|field| field.respond_to?(:strip) ? field.strip : field }
    # res = []
    # outputs.each do |this|
    #     res << CSV.parse(this, 
    #     headers: true, 
    #     header_converters: :downcase, 
    #     converters: :all, 
    #     quote_char: '"', 
    #     force_quotes: true)
    # end

    # s = CSV.generate(write_converters: strip_converter) do |d|
    #     d << res.first.headers  # hedrs are allthe smae
    #     res.each do |table|
    #         table.each do |row|
    #             d << CSV::Row.new(res.first.headers, row.deconstruct)
    #         end
    #     end
    # end
    # warn "CSV IS\n#{s}\n\n"    

    location = SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"

    resp = RestClient::Request.execute(
        method: :put,
        url: "https://bgv.cbgp.upm.es/DAV/home/LDP/#{location}",
        content_type: :json,
        payload: results.to_json, 
        user: "ldp",
        password: "ldp"
    )
    warn resp.headers.inspect
    location2 = resp.headers[:location]
    warn "LOCATION #{location2}"
    return location
end
