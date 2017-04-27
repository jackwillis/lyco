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

set :public_folder, File.join(File.dirname(__FILE__), "..", "public")
set :views, File.join(File.dirname(__FILE__), "..", "views")

get "/" do
  erb :index
end
