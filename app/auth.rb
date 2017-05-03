require "bcrypt"

set :app_pass, BCrypt::Password.new(ENV["LYCO_SECRET"])

use Rack::Auth::Basic do |username, password|
  settings.app_pass == (username + ":" + password)
end