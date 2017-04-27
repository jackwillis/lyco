require "sinatra-websocket"

set :sockets, []

def send_ws(msg)
  EM.next_tick do
    settings.sockets.each do |s|
      s.send(msg)
    end
  end
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
EM.next_tick do
  EM.add_periodic_timer(2) do
    send_ws "__ping__"
  end
end