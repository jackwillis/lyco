require "sinatra"

########

require "twilio-ruby"

account_sid = ENV["TWILIO_ACCOUNT_SID"]
fail "no TWILIO_ACCOUNT_SID environment variable" unless account_sid

auth_token = ENV["TWILIO_AUTH_TOKEN"]
fail "no TWILIO_AUTH_TOKEN environment variable" unless auth_token

set :sender, ENV["TWILIO_SENDER"]
fail "no TWILIO_SENDER environment variable" unless settings.sender

set :sms_client, Twilio::REST::Client.new(account_sid, auth_token)

########

require "redis"

redis_url = ENV["REDIS_URL"]
fail "no REDIS_URL environment variable" unless redis_url

set :redis, Redis.new(url: redis_url)

# ensure Redis is running
begin
  settings.redis.ping
rescue Redis::CannotConnectError => e
  fail "Cannot connect to redis at #{redis_url}"
end

########

require "bcrypt"

lyco_secret = ENV["LYCO_SECRET"]
fail "no LYCO_SECRET environment variable" unless lyco_secret

set :app_pass, BCrypt::Password.new(lyco_secret)

use Rack::Auth::Basic do |username, password|
  settings.app_pass == (username + ":" + password)
end

########

set :public_folder, File.join(File.dirname(__FILE__), "..", "public")
set :views, File.join(File.dirname(__FILE__), "..", "views")

require "logger"

set :log, Logger.new(STDOUT)

require_relative "utils"
require_relative "database"
require_relative "texting"
require_relative "websockets"
require_relative "settings"

if ENV["CANONICAL_HOST"]
  require "rack-canonical-host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end