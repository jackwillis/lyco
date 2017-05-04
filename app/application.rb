ACCOUNT_SID = ENV["TWILIO_ACCOUNT_SID"]
fail "no TWILIO_ACCOUNT_SID environment variable" unless ACCOUNT_SID

AUTH_TOKEN = ENV["TWILIO_AUTH_TOKEN"]
fail "no TWILIO_AUTH_TOKEN environment variable" unless AUTH_TOKEN

SENDER = ENV["TWILIO_SENDER"]
fail "no TWILIO_SENDER environment variable" unless AUTH_TOKEN

REDIS_URL = ENV["REDIS_URL"]
fail "no REDIS_URL environment variable" unless REDIS_URL

require "redis"
$redis = Redis.new(url: REDIS_URL)

# ensure Redis is running
begin
  $redis.ping
rescue Redis::CannotConnectError => e
  fail "Cannot connect to redis at #{REDIS_URL}"
end

require_relative "server"

if ENV["CANONICAL_HOST"]
  require "rack-canonical-host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end