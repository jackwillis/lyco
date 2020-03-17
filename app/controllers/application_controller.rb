# HTTP Basic Authentication

use Rack::Auth::Basic do |username, password|
  [settings.username, settings.password] == [username, password]
end
