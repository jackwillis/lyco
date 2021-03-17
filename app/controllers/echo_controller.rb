# Twilio makes a request to this URL when
# someone sends a text to our number
get '/echo' do
  from = params[:From].to_s.strip
  body = params[:Body].to_s.strip

  return 400 if from.empty? || body.empty?

  forward_incoming_message!(from: from, body: body)

  automated_reply_xml
end

def forward_incoming_message!(from:, body:)
  settings.log.info("#{from} replied: #{body}")

  replies_forwardee = settings.settings_db.replies_forwardee

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")
  settings.log.info("#{from}'s message was forwarded to #{replies_forwardee}")
end

def automated_reply_xml
  autoreply_disabled = !settings.settings_db.autoreply_mode?
  autoreply_message_empty = settings.settings_db.automated_reply.to_s.empty?
  return 204 if autoreply_disabled || autoreply_message_empty

  content_type :xml

  response = Twilio::TwiML::MessagingResponse.new
  response.message(body: settings.settings_db.automated_reply)
  response.to_s
end
