ENV["RACK_ENV"] = "test"

require "bcrypt"

ENV["LYCO_SECRET"] = BCrypt::Password.create("foo:bar")

require "pry"
require "rack/test"
require "rspec"
require "rspec-html-matchers"
require_relative "twilio_helpers"

require_relative "../app/application"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers

  def app
    @_app ||= Sinatra::Application.new
  end

  def settings
    app.settings
  end

  def db
    settings.db
  end

  settings.set :sms_client, FakeSMSClient.new

  def sms_client
    settings.sms_client
  end

  def sender
    settings.sender
  end

  config.before(:each) do |example|
    unless example.metadata[:no_auth]
      basic_authorize "foo", "bar"
    end

    if example.metadata[:with_db]
      db.reset!
    end

    if example.metadata[:with_sms]
      sms_client.reset!
    end
  end
end
