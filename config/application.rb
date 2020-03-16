require 'logger'

require 'bundler'
Bundler.require(:default)

set :public_folder, File.join(File.dirname(__FILE__), '..', 'app', 'assets')
set :views,         File.join(File.dirname(__FILE__), '..', 'app', 'views')

set :instance_name, ENV['INSTANCE_NAME']

# Are we being loaded by automated tests?
def testing?
  ENV["APP_ENV"] == 'test' ||
  ENV["RACK_ENV"] == 'test'
end

require_relative 'environment' unless testing?

require_relative '../app/models/settings'
require_relative 'seeds'
set :settings_db, SettingsDatabase.new(settings.redis)

require_relative '../app/controllers/application_controller'
require_relative '../app/controllers/compose_controller'
require_relative '../app/controllers/echo_controller'
require_relative '../app/controllers/logs_controller'
require_relative '../app/controllers/settings_controller'