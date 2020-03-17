ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:default, :test)

SimpleCov.start

require_relative 'fakes'
require_relative 'environment'

# Bring in the application
require_relative '../config/application'

module LycoRSpecHelpers
  def app
    @app ||= Sinatra::Application.new
  end

  def settings
    app.settings
  end

  def sms_client
    settings.sms_client
  end

  def sender
    settings.sender
  end

  def settings_db
    settings.settings_db
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
  config.include LycoRSpecHelpers

  config.before(:each) do |example|
    basic_authorize(settings.username, settings.password) \
      unless example.metadata[:no_auth]
    settings_db.reset! if example.metadata[:with_db]
    sms_client.reset! if example.metadata[:with_sms]
  end
end
