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

require "sinatra"

require_relative "utils"
require_relative "texting"
require_relative "websockets"
require_relative "settings"
require_relative "auth"

set :public_folder, File.join(File.dirname(__FILE__), "..", "public")
set :views, File.join(File.dirname(__FILE__), "..", "views")

if ENV["CANONICAL_HOST"]
  require "rack-canonical-host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end