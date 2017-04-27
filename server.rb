require "sinatra"
require "sinatra-websocket"

require_relative "texting"

class Hash
  def require(keys)
    Hash[keys.uniq.map { |k| [k, self[k] ] }]
  end
end

set :static, true # serve assets from public/
set :automated_reply_filename, File.join(".", "data", "reply.txt")
set :replies_forwardee_filename, File.join(".", "data", "forwardee.txt")
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

# Twilio makes a request to this URL when
# someone sends a text to our number
get "/echo" do
  reply_text = File.read(settings.automated_reply_filename)

  from = params[:From]
  body = params[:Body]

  log = Logger.new(STDOUT)

  log.info("#{from} replied")

  replies_forwardee = File.read(settings.replies_forwardee_filename).strip

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")

  log.info("#{from}'s message was forwarded to #{replies_forwardee}")

  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Sms reply_text
  end

  response.text
end

get "/settings" do
  @automated_reply = File.read(settings.automated_reply_filename).strip
  @replies_forwardee = File.read(settings.replies_forwardee_filename).strip

  erb :settings
end

post "/settings" do
  File.write(settings.automated_reply_filename, params[:automated_reply].strip)
  File.write(settings.replies_forwardee_filename, params[:replies_forwardee].strip)

  redirect "/settings"
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
