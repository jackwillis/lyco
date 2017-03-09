require_relative "server"

require "rack-canonical-host"
require "bcrypt"

use Rack::CanonicalHost, ENV["CANONICAL_HOST"] if ENV["CANONICAL_HOST"]

set :app_pass, BCrypt::Password.new(ENV["LYCO_SECRET"])

use Rack::Auth::Basic do |username, password|
  settings.app_pass == (username + ":" + password)
end

run Sinatra::Application