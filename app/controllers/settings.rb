# Twilio makes a request to this URL when
# someone sends a text to our number
get "/echo" do
  from = params[:From].to_s.strip
  body = params[:Body].to_s.strip

  return 401 if from.empty? or body.empty?

  forward_incoming_message!(from: from, body: body)

  automated_reply_xml
end

get "/settings" do
  @automated_reply = settings.db.automated_reply
  @replies_forwardee = settings.db.replies_forwardee 

  erb :settings
end

post "/settings" do
  reply = params[:automated_reply]
  forwardee = params[:replies_forwardee]

  settings.db.automated_reply = reply.strip if reply
  settings.db.replies_forwardee = forwardee.normalize_newlines.strip if forwardee

  redirect "/settings"
end

def forward_incoming_message!(from:, body:)
  settings.log.info("#{from} replied: #{body}")

  replies_forwardee = settings.db.replies_forwardee

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")

  settings.log.info("#{from}'s message was forwarded to #{replies_forwardee}")
end

def automated_reply_xml
  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Sms settings.db.automated_reply
  end

  response.text
end