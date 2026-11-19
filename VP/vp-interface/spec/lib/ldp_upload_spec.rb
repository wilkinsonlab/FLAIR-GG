# frozen_string_literal: false

require_relative '../spec_helper'

# process_and_upload_output (lib/serviceoutput_processers/general.rb).
# spec_helper sets LDP_HOST=http://ldp.test; LDP_INTERNAL_HOST is unset by default.
RSpec.describe 'process_and_upload_output' do
  let(:results) { { 'https://provider.example.org/data' => 'rows' } }

  before { allow(HttpRetry).to receive(:pause) }

  context 'without LDP_INTERNAL_HOST (upload to the public LDP_HOST, as before)' do
    it "PUTs to LDP_HOST and returns Virtuoso's Location" do
      stub_request(:put, %r{\Ahttp://ldp\.test/DAV/home/LDP/FLAIR/[0-9a-f-]{36}\z})
        .with(basic_auth: %w[test-ldp-user test-ldp-password])
        .to_return(status: 201, headers: { 'Location' => 'http://ldp.test/DAV/home/LDP/FLAIR/abc' })

      expect(process_and_upload_output(results: results)).to eq('http://ldp.test/DAV/home/LDP/FLAIR/abc')
    end

    it 'falls back to the uploaded URL when Virtuoso sends no Location' do
      stub_request(:put, %r{\Ahttp://ldp\.test/DAV/home/LDP/FLAIR/}).to_return(status: 201)

      expect(process_and_upload_output(results: results))
        .to match(%r{\Ahttp://ldp\.test/DAV/home/LDP/FLAIR/[0-9a-f-]{36}\z})
    end

    it 'retries a transient failure' do
      stub_request(:put, %r{\Ahttp://ldp\.test/DAV/home/LDP/FLAIR/})
        .to_raise(Errno::ECONNRESET.new('SSL_connect')).then
        .to_return(status: 201, headers: { 'Location' => 'http://ldp.test/DAV/home/LDP/FLAIR/abc' })

      expect(process_and_upload_output(results: results)).to eq('http://ldp.test/DAV/home/LDP/FLAIR/abc')
    end

    it 'returns nil (CACHING SERVER IS DOWN) when the upload keeps failing' do
      stub_request(:put, %r{\Ahttp://ldp\.test/}).to_return(status: 401)

      expect(process_and_upload_output(results: results)).to be_nil
    end
  end

  context 'with LDP_INTERNAL_HOST set' do
    before { stub_const('VPConfig::LDP_INTERNAL_HOST', 'http://ldp:8890') }

    it 'PUTs to the internal host with the public Host header, and returns a public URL' do
      stub_request(:put, %r{\Ahttp://ldp:8890/DAV/home/LDP/FLAIR/[0-9a-f-]{36}\z})
        .with(headers: { 'Host' => 'ldp.test' })
        .to_return(status: 201, headers: { 'Location' => 'http://ldp.test:8890/DAV/home/LDP/FLAIR/abc' })

      expect(process_and_upload_output(results: results)).to eq('http://ldp.test/DAV/home/LDP/FLAIR/abc')
    end

    it 'makes a relative or missing Location public too' do
      stub_request(:put, %r{\Ahttp://ldp:8890/}).to_return(status: 201)

      expect(process_and_upload_output(results: results))
        .to match(%r{\Ahttp://ldp\.test/DAV/home/LDP/FLAIR/[0-9a-f-]{36}\z})
    end
  end
end
