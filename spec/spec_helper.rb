ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:default, :test)

SimpleCov.start

require_relative 'fakes'

# Fake environment variables
set :sms_client, FakeSMSClient.new
set :log, Logger.new(StringIO.new)
set :redis, FakeRedisClient.new
set :username, 'foo'
set :password, 'bar'
set :sender, '15005550006'

require_relative '../config/application'

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

  def db
    settings.db
  end

  config.before(:each) do |example|
    unless example.metadata[:no_auth]
      basic_authorize 'foo', 'bar'
    end

    if example.metadata[:with_db]
      db.reset!
    end

    if example.metadata[:with_sms]
      sms_client.reset!
    end
  end
end
