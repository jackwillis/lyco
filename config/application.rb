require 'logger'

require 'bundler'
Bundler.require(:default)

# `set(k, v)` builds Sinatra's `settings` object...

set :instance_name, ENV['INSTANCE_NAME']

app_folder = File.join(File.dirname(__FILE__), '..', 'app')
set :public_folder, File.join(app_folder, 'assets')
set :views, File.join(app_folder, 'views')

# Are we being loaded by automated tests?
def testing?
  ENV['APP_ENV'] == 'test' || ENV['RACK_ENV'] == 'test'
end

require_relative 'environment' unless testing?

require_relative '../app/helpers'

require_relative 'default_settings'
require_relative '../app/models/settings'
set :settings_db, SettingsDatabase.new(settings.redis)

require_relative '../app/controllers/application_controller'
require_relative '../app/controllers/compose_controller'
require_relative '../app/controllers/echo_controller'
require_relative '../app/controllers/logs_controller'
require_relative '../app/controllers/settings_controller'
