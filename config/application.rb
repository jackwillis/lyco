require "sinatra"
require "logger"
require "redis"
require "twilio-ruby"

# Are we being loaded by automated tests?
def testing?
  ENV["APP_ENV"] == "test" ||
  ENV["RACK_ENV"] == "test"
end

require_relative "environment" unless testing?

require_relative "../app/database"
set :db, DatabaseService.new(settings.redis)

require_relative "../app/controllers/application"
require_relative "../app/controllers/echo"
require_relative "../app/controllers/settings"
require_relative "../app/controllers/texting"
require_relative "../app/controllers/websockets"

set :public_folder, File.join(File.dirname(__FILE__), "..", "app", "assets")
set :views,         File.join(File.dirname(__FILE__), "..", "app", "views")