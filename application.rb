require 'logger'

require 'bundler'
Bundler.require(:default)

# This is a Sinatra application.
# Read more about `set`: http://sinatrarb.com/configuration.html

set :instance_name, ENV['INSTANCE_NAME']

set :public_folder, File.join(File.dirname(__FILE__), 'app', 'assets')
set :views, File.join(File.dirname(__FILE__), 'app', 'views')

# Are we being loaded by automated tests?
def testing?
  ENV['APP_ENV'] == 'test' || ENV['RACK_ENV'] == 'test'
end

require_relative 'config/environment' unless testing?

require_relative 'app/helpers'

require_relative 'config/default_settings'
require_relative 'app/models/settings'
set :settings_db, SettingsDatabase.new(settings.redis)

require_relative 'app/controllers/application_controller'
require_relative 'app/controllers/compose_controller'
require_relative 'app/controllers/echo_controller'
require_relative 'app/controllers/logs_controller'
require_relative 'app/controllers/settings_controller'
