ACCOUNT_SID = ENV["TWILIO_ACCOUNT_SID"]
fail "no TWILIO_ACCOUNT_SID in env" unless ACCOUNT_SID

AUTH_TOKEN = ENV["TWILIO_AUTH_TOKEN"]
fail "no TWILIO_AUTH_TOKEN in env" unless AUTH_TOKEN

SENDER = ENV["TWILIO_SENDER"]
fail "no TWILIO_SENDER in env" unless AUTH_TOKEN

require_relative "server"

require "rack-canonical-host"

use Rack::CanonicalHost, ENV["CANONICAL_HOST"] if ENV["CANONICAL_HOST"]

require "bcrypt"

set :app_pass, BCrypt::Password.new(ENV["LYCO_SECRET"])

class LycoAuth < Rack::Auth::Basic
  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when "/echo"
      @app.call(env) # skip http authentication on webhooks
    else
      super
    end
  end
end

use LycoAuth do |username, password|
  settings.app_pass == (username + ":" + password)
end

run Sinatra::Application
