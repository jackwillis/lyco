require "bcrypt"

set :app_pass, BCrypt::Password.new(ENV["LYCO_SECRET"])

class LycoAuth < Rack::Auth::Basic
  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when "/echo"
      @app.call(env) # skip basic auth on webhook url
    else
      super
    end
  end
end

use LycoAuth do |username, password|
  settings.app_pass == (username + ":" + password)
end