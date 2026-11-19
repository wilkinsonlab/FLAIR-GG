# frozen_string_literal: false

require_relative '../spec_helper'

RSpec.describe HttpRetry do
  before { allow(described_class).to receive(:pause) } # no real sleeping

  def handshake_reset
    Errno::ECONNRESET.new('SSL_connect')
  end

  def status_error(code)
    RestClient::ExceptionWithResponse.new(instance_double('RestClient::Response', code: code), code)
  end

  describe '.retryable?' do
    it 'retries connect-phase failures for any method' do
      [handshake_reset, RestClient::Exceptions::OpenTimeout.new, Errno::ECONNREFUSED.new, SocketError.new,
       OpenSSL::SSL::SSLError.new('SSL_connect returned=1 errno=0 state=error')].each do |e|
        expect(described_class.retryable?(e, idempotent: false)).to be(true), e.inspect
      end
    end

    it 'retries Cloudflare origin-unreached statuses (521/522/523) for any method' do
      expect(described_class.retryable?(status_error(522), idempotent: false)).to be true
    end

    it 'retries maybe-sent failures only for idempotent methods' do
      [Errno::ECONNRESET.new('read'), status_error(502), status_error(524)].each do |e|
        expect(described_class.retryable?(e, idempotent: true)).to be(true), e.inspect
        expect(described_class.retryable?(e, idempotent: false)).to be(false), e.inspect
      end
    end

    it 'never retries read timeouts, certificate failures, or ordinary HTTP errors' do
      [RestClient::Exceptions::ReadTimeout.new,
       OpenSSL::SSL::SSLError.new('SSL_connect returned=1 errno=0 state=error: certificate verify failed'),
       status_error(404), status_error(500)].each do |e|
        expect(described_class.retryable?(e, idempotent: true)).to be(false), e.inspect
      end
    end
  end

  describe '.with_retries' do
    it 'returns the result once a retry succeeds' do
      calls = 0
      result = described_class.with_retries(label: 'test') do
        calls += 1
        raise handshake_reset if calls < 3

        :ok
      end
      expect([result, calls]).to eq([:ok, 3])
    end

    it 're-raises the last error after ATTEMPTS tries' do
      calls = 0
      expect do
        described_class.with_retries(label: 'test') do
          calls += 1
          raise handshake_reset
        end
      end.to raise_error(Errno::ECONNRESET)
      expect(calls).to eq(HttpRetry::ATTEMPTS)
    end

    it 'does not retry a non-retryable error' do
      calls = 0
      expect do
        described_class.with_retries(label: 'test') do
          calls += 1
          raise ArgumentError, 'bug'
        end
      end.to raise_error(ArgumentError)
      expect(calls).to eq(1)
    end
  end
end

RSpec.describe 'Service.execute_get / execute_post retries (lib/services.rb)' do
  before { allow(HttpRetry).to receive(:pause) }

  it 'execute_get retries a TLS-handshake reset and returns the response' do
    stub_request(:get, 'https://provider.example.org/data')
      .to_raise(Errno::ECONNRESET.new('SSL_connect')).then
      .to_return(status: 200, body: 'rows')

    expect(Service.execute_get(endpoint: 'https://provider.example.org/data', params: {}).body).to eq('rows')
  end

  it 'execute_get still raises once retries are used up' do
    stub_request(:get, 'https://provider.example.org/data').to_raise(Errno::ECONNRESET.new('SSL_connect'))

    expect { Service.execute_get(endpoint: 'https://provider.example.org/data', params: {}) }
      .to raise_error(Errno::ECONNRESET)
    expect(a_request(:get, 'https://provider.example.org/data')).to have_been_made.times(HttpRetry::ATTEMPTS)
  end

  it 'execute_post retries a handshake reset (nothing was sent)' do
    stub_request(:post, 'https://provider.example.org/query')
      .to_raise(Errno::ECONNRESET.new('SSL_connect')).then
      .to_return(status: 200, body: 'posted')

    result = Service.execute_post(endpoint: 'https://provider.example.org/query', body: { '_request_body' => '{}' })
    expect(result.body).to eq('posted')
  end

  it 'execute_post does not repeat a request that may have been sent' do
    stub_request(:post, 'https://provider.example.org/query').to_raise(Errno::ECONNRESET.new('read'))

    result = Service.execute_post(endpoint: 'https://provider.example.org/query', body: { '_request_body' => '{}' })
    expect(result).to be_nil
    expect(a_request(:post, 'https://provider.example.org/query')).to have_been_made.once
  end
end
