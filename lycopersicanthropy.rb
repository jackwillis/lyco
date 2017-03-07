require "sinatra"
require "sinatra-websocket"
require "bcrypt"

set :app_pass, BCrypt::Password.new(ENV["LYCO_SECRET"])
set :sockets, []

def send_ws(msg)
  EM.next_tick do
    settings.sockets.each do |s|
      s.send(msg)
    end
  end
end

def process_texts(params)
  10.times do |n| send_ws "Processing text #{n}\n"; sleep 0.1; end
  send_ws "Done\n"
end

use Rack::Auth::Basic do |username, password|
  settings.app_pass == (username + ":" + password)
end

get "/" do
  erb :index
end

post "/" do
  Thread.new { process_texts(params)  }
  204
end

get "/ws" do
  request.websocket do |ws|
    ws.onopen do
      ws.send("No logs to show\n")
      settings.sockets << ws
    end

    ws.onclose do
      warn("websocket closed")
      settings.sockets.delete(ws)
    end
  end
end

# heartbeat
Thread.new do
  loop do
    sleep 1
    send_ws ""
  end
end
