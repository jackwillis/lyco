require "sinatra"

class Hash
  def require(keys)
    Hash[keys.uniq.map { |k| [k, self[k] ] }]
  end
end

require_relative "texting"
require_relative "websockets"
require_relative "settings"
require_relative "auth"

set :static, true # serve assets from public/

get "/" do
  erb :index
end
