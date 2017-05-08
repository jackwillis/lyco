require "sinatra"
require "bcrypt"
require "logger"
require "redis"
require "twilio-ruby"

unless ENV["APP_ENV"] == "test" or ENV["RACK_ENV"] == "test"
  require_relative "environment"
end

require_relative "helpers"
require_relative "database"
require_relative "controllers/texting"
require_relative "controllers/websockets"
require_relative "controllers/settings"

set :public_folder, File.join(File.dirname(__FILE__), "..", "public")
set :views, File.join(File.dirname(__FILE__), "..", "views")

use Rack::Auth::Basic do |username, password|
  settings.app_pass == (username + ":" + password)
end

if ENV["CANONICAL_HOST"]
  require "rack-canonical-host"
  use Rack::CanonicalHost, ENV["CANONICAL_HOST"]
end