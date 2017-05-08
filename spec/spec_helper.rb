ENV["RACK_ENV"] = "test"

require "bcrypt"

ENV["LYCO_SECRET"] = BCrypt::Password.create("foo:bar")

require_relative "../app/application"

require "rack/test"
require "rspec"
require "rspec-html-matchers"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers

  def app
    Sinatra::Application.new
  end

  def db
    app.settings.db
  end

  config.before(:each) do |example|
    unless example.metadata[:no_auth]
      basic_authorize "foo", "bar"
    end

    if example.metadata[:with_db]
      db.reset!
    end
  end
end
