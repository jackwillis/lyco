# Twilio makes a request to this URL when
# someone sends a text to our number
get "/echo" do
  from = params[:From].to_s.strip
  body = params[:Body].to_s.strip

  return 400 if from.empty? or body.empty?

  forward_incoming_message!(from: from, body: body)

  automated_reply_xml
end

get "/settings" do
  @automated_reply = settings.db.automated_reply
  @replies_forwardee = settings.db.replies_forwardee 
  @autoreply_mode = settings.db.autoreply_mode?

  erb :settings
end

post "/settings" do
  reply = params[:automated_reply]&.normalize_newlines&.strip
  settings.db.automated_reply = reply

  forwardee = params[:replies_forwardee]&.normalize_newlines&.strip
  settings.db.replies_forwardee = forwardee

  autoreply_mode = params[:autoreply_mode] == 'on'
  settings.db.autoreply_mode = autoreply_mode

  redirect "/settings"
end

def forward_incoming_message!(from:, body:)
  settings.log.info("#{from} replied: #{body}")

  replies_forwardee = settings.db.replies_forwardee

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")
  settings.log.info("#{from}'s message was forwarded to #{replies_forwardee}")
end

def automated_reply_xml
  return 204 unless db.autoreply_mode?

  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Sms settings.db.automated_reply
  end

  response.text
end
