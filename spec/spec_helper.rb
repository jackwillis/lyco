# Loading the test environment

ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:default, :test)

SimpleCov.start

require_relative 'fakes'

# Fake environment variables
set :sms_client, FakeTwilioRESTClient.new
set :log, Logger.new(StringIO.new)
set :redis, FakeRedis.new
set :username, 'foo'
set :password, 'bar'
set :sender, '15005550006'

# Bring in the application
require_relative '../config/application'

# RSpec helpers
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers

  def app
    @_app ||= Sinatra::Application.new
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

  config.before(:each) do |example|
    unless example.metadata[:no_auth]
      basic_authorize settings.username, settings.password
    end

    if example.metadata[:with_db]
      settings_db.reset!
    end

    if example.metadata[:with_sms]
      sms_client.reset!
    end
  end
end
