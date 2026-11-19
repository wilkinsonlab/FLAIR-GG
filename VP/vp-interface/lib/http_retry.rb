# frozen_string_literal: true

require 'openssl'
require 'socket'
require 'rest-client'

# Retries an outbound HTTP call when it fails in a way that is usually a
# brief network fault, not a real error from the service.
#
# Why this exists: in Nov 2026, connections between the VP's host and
# Cloudflare intermittently failed. Some were reset during the TLS handshake
# (Errno::ECONNRESET "SSL_connect"), and some got Cloudflare 52x
# "origin unreachable" answers. A reload a second later usually worked.
# Without retries, a single such failure became an application-error page
# for the user.
#
# What is retried depends on whether the request could already have reached
# the service:
# - Connect-phase failures (connect timeout, refused, DNS, TLS handshake
#   reset) and Cloudflare 521/522/523 (Cloudflare never reached the origin)
#   mean nothing was sent, so they are retried for any method, POST included.
# - Failures after the request may have been sent (reset mid-response,
#   broken pipe, 502/503/504/520/524) are retried only for idempotent
#   methods (GET, PUT).
# - Read timeouts are never retried. A service that is slow to answer
#   would be slow again, and repeating it would push the user's browser
#   request past Cloudflare's own 100 s limit.
module HttpRetry
  ATTEMPTS = 3          # total tries, including the first
  OPEN_TIMEOUT = 15     # seconds to establish TCP + TLS (RestClient's default is 60)

  CONNECT_ERRORS = [
    RestClient::Exceptions::OpenTimeout,
    Errno::ECONNREFUSED,
    Errno::EHOSTUNREACH,
    Errno::ENETUNREACH,
    SocketError, # DNS resolution failure
    OpenSSL::SSL::SSLError
  ].freeze

  MAYBE_SENT_ERRORS = [
    Errno::ECONNRESET,
    Errno::EPIPE,
    RestClient::ServerBrokeConnection
  ].freeze

  # Cloudflare could not reach the origin, so the request was never processed.
  ORIGIN_UNREACHED_STATUSES = [521, 522, 523].freeze
  # A gateway answered with an error, but the origin may have processed the request.
  GATEWAY_STATUSES = [502, 503, 504, 520, 524].freeze

  # Runs the block, retrying it (up to ATTEMPTS tries in total) when it raises
  # a transient error, as described above. Re-raises the last error if every
  # attempt fails, or immediately for any error that isn't retryable.
  #
  # @param label [String] what is being called, for the log line
  # @param idempotent [Boolean] false for POST: only retry when nothing was sent
  def self.with_retries(label:, idempotent: true, attempts: ATTEMPTS)
    attempt = 0
    begin
      attempt += 1
      yield
    rescue StandardError => e
      raise unless attempt < attempts && retryable?(e, idempotent: idempotent)

      warn "HttpRetry: #{label} - attempt #{attempt}/#{attempts} failed (#{e.class}: #{e.message}); retrying"
      pause(attempt)
      retry
    end
  end

  def self.retryable?(error, idempotent:)
    return true if connect_phase?(error)

    status = error.respond_to?(:http_code) ? error.http_code : nil
    return true if ORIGIN_UNREACHED_STATUSES.include?(status)
    return false unless idempotent

    MAYBE_SENT_ERRORS.any? { |klass| error.is_a?(klass) } || GATEWAY_STATUSES.include?(status)
  end

  def self.connect_phase?(error)
    # A certificate the host will keep presenting is not going to change on retry.
    return false if error.is_a?(OpenSSL::SSL::SSLError) && error.message.include?('certificate verify failed')
    return true if CONNECT_ERRORS.any? { |klass| error.is_a?(klass) }

    # Ruby reports a reset during the TLS handshake as ECONNRESET "... - SSL_connect"
    error.is_a?(Errno::ECONNRESET) && error.message.include?('SSL_connect')
  end

  # Short, growing pause between attempts (1 s, then 2 s). A separate method so specs can stub it.
  def self.pause(attempt)
    sleep(attempt)
  end
end
