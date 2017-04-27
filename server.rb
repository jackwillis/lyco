require "sinatra"

require_relative "texting"
require_relative "websockets"
require_relative "settings"

class Hash
  def require(keys)
    Hash[keys.uniq.map { |k| [k, self[k] ] }]
  end
end

set :static, true # serve assets from public/

get "/" do
  erb :index
end

post "/" do
  safe_params = params.require(%i[
    numbers message
  ])

  Thread.new do
    process_texts(params) do |chunk|
      send_ws(chunk)
    end
  end

  204
end
