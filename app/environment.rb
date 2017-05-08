def require_env(name)
  ENV[name] or fail "no #{name} environment variable"
end

account_sid = require_env("TWILIO_ACCOUNT_SID")
auth_token = require_env("TWILIO_AUTH_TOKEN")

set :sender, require_env("TWILIO_SENDER")
set :sms_client, Twilio::REST::Client.new(account_sid, auth_token)

redis_url = require_env("REDIS_URL")

set :redis, Redis.new(url: redis_url)

# ensure Redis is running
begin
  settings.redis.ping
rescue Redis::CannotConnectError => e
  fail "Cannot connect to redis at #{redis_url}"
end

set :app_pass, BCrypt::Password.new(require_env("LYCO_SECRET"))
set :log, Logger.new(STDOUT)