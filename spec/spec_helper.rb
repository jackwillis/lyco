ENV["RACK_ENV"] = "test"

require "bcrypt"

ENV["LYCO_SECRET"] = BCrypt::Password.create("foo:bar")

require_relative "../app/application"

require "rack/test"
require "rspec"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  def use_credentials
    basic_authorize "foo", "bar"
  end
end
