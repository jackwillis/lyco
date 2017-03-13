require "sinatra"
require "sinatra-websocket"

require_relative "texting"

class Hash
  def require(keys)
    Hash[keys.uniq.map { |k| [k, self[k] ] }]
  end
end

set :static, true # serve assets from public/

set :sockets, []

def send_ws(msg)
  EM.next_tick do
    settings.sockets.each do |s|
      s.send(msg)
    end
  end
end

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

get "/ws" do
  request.websocket do |ws|
    ws.onopen do
      ws.send("Connected\n")
      settings.sockets << ws
    end

    ws.onclose do
      warn("websocket closed")
      settings.sockets.delete(ws)
    end
  end
end

# heartbeat
EM.run do
  EM.add_periodic_timer(2) do
    send_ws "__ping__"
  end
end
