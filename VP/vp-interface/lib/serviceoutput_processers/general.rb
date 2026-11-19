require "csv"
require "rest-client"
require 'securerandom'
require 'json'
require 'uri'
require_relative '../http_retry'

# Stores the aggregated service results on the project LDP server and
# returns their public URL (the "secret key" shown to users is its last
# path segment). Returns nil if the upload fails, and the page then says
# "CACHING SERVER IS DOWN".
def process_and_upload_output(results: )  # results[provider] = csv/json
    key = SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"
    path = "/DAV/home/LDP/FLAIR/#{key}"
    upload_url = "#{LdpUpload.upload_base}#{path}"
    begin
        resp = HttpRetry.with_retries(label: "LDP upload #{upload_url}") do # PUT is idempotent
            RestClient::Request.execute(
                method: :put,
                url: upload_url,
                content_type: :json,
                payload: results.to_json,
                user: VPConfig::LDP_USERNAME,
                password: VPConfig::LDP_PASSWORD,
                open_timeout: HttpRetry::OPEN_TIMEOUT,
                headers: LdpUpload.extra_headers
            )
        end
    rescue StandardError => e
        warn "LDP upload to #{upload_url} failed: #{e.class}: #{e.message}"
        return nil
    end
    warn resp.headers.inspect
    location = resp.headers[:location]  # where did it really put it?
    public_location = LdpUpload.public_location(location: location, upload_url: upload_url)
    warn "LOCATION #{location} -> #{public_location}"
    public_location
end

# Helpers for uploading to LDP_INTERNAL_HOST while handing out LDP_HOST URLs.
module LdpUpload
    def self.upload_base
        VPConfig::LDP_INTERNAL_HOST || VPConfig::LDP_HOST
    end

    # When uploading internally, send the public Host header, so Virtuoso
    # handles the request exactly as it would one arriving through the proxy.
    def self.extra_headers
        return {} unless VPConfig::LDP_INTERNAL_HOST

        { 'Host' => URI(VPConfig::LDP_HOST).host }
    end

    # The URL to give users and notebooks for the stored results.
    # Virtuoso's Location header names the host it was contacted on, so after
    # an internal upload it is rewritten onto LDP_HOST. If Virtuoso sends no
    # Location, the URL that was PUT to is used.
    def self.public_location(location:, upload_url:)
        absolute = URI.join(upload_url, location || upload_url)
        return absolute.to_s unless VPConfig::LDP_INTERNAL_HOST

        "#{VPConfig::LDP_HOST}#{absolute.request_uri}"
    end
end
