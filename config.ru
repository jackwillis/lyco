ACCOUNT_SID = ENV["TWILIO_ACCOUNT_SID"]
fail "no TWILIO_ACCOUNT_SID environment variable" unless ACCOUNT_SID

AUTH_TOKEN = ENV["TWILIO_AUTH_TOKEN"]
fail "no TWILIO_AUTH_TOKEN environment variable" unless AUTH_TOKEN

SENDER = ENV["TWILIO_SENDER"]
fail "no TWILIO_SENDER environment variable" unless AUTH_TOKEN

if ENV["CANONICAL_HOST"]
  require "rack-canonical-host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end

require_relative "server"

run Sinatra::Application
