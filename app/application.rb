require "sinatra"

def require_env(name)
  ENV[name] or fail "no #{name} environment variable"
end

########

require "twilio-ruby"

account_sid = require_env("TWILIO_ACCOUNT_SID")
auth_token = require_env("TWILIO_AUTH_TOKEN")

set :sender, require_env("TWILIO_SENDER")
set :sms_client, Twilio::REST::Client.new(account_sid, auth_token)

########

require "redis"

redis_url = require_env("REDIS_URL")

set :redis, Redis.new(url: redis_url)

# ensure Redis is running
begin
  settings.redis.ping
rescue Redis::CannotConnectError => e
  fail "Cannot connect to redis at #{redis_url}"
end

########

require "bcrypt"

lyco_secret = require_env("LYCO_SECRET")

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