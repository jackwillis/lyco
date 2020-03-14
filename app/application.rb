require "sinatra"
require "logger"
require "redis"
require "twilio-ruby"

def testing?
  ENV["APP_ENV"] == "test" ||
  ENV["RACK_ENV"] == "test"
end

require_relative "environment" unless testing?

require_relative "helpers"
require_relative "database"

require_relative "controllers/texting"
require_relative "controllers/websockets"
require_relative "controllers/settings"

set :public_folder, File.join(File.dirname(__FILE__), "..", "public")
set :views,         File.join(File.dirname(__FILE__), "..", "views")

# HTTP Basic Authentication

use Rack::Auth::Basic do |username, password|
  [settings.username, settings.password] == [username, password]
end