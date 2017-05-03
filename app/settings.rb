# Twilio makes a request to this URL when
# someone sends a text to our number
get "/echo" do
  from = params[:From].to_s.strip
  body = params[:Body].to_s.strip

  return 401 if from.empty? or body.empty?

  forward_incoming_message!(from: from, body: body)

  automated_reply
end

get "/settings" do
  @automated_reply = Settings.automated_reply
  @replies_forwardee = Settings.replies_forwardee 

  erb :settings
end

post "/settings" do
  Settings.automated_reply = params[:automated_reply]
  Settings.replies_forwardee = params[:replies_forwardee]

  redirect "/settings"
end

def forward_incoming_message!(from:, body:)
  log = Logger.new(STDOUT)

  log.info("#{from} replied: #{body}")

  replies_forwardee = Settings.replies_forwardee

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")

  log.info("#{from}'s message was forwarded to #{replies_forwardee}")
end

def automated_reply
  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Sms Settings.automated_reply
  end

  response.text
end

module Settings
  DEFAULT_AUTOMATED_REPLY = <<~EOF
    Hello! You have received an automated text message.

    To unsubscribe, please reply STOP.
  EOF

  DEFAULT_REPLIES_FORWARDEE = "15005550006"

  def self.automated_reply
    $redis.get(:lyco_automatic_reply) || DEFAULT_AUTOMATED_REPLY
  end

  def self.automated_reply=(reply)
    $redis.set(:lyco_automatic_reply, reply)
  end

  def self.replies_forwardee
    $redis.get(:lyco_replies_forwardee) || DEFAULT_REPLIES_FORWARDEE
  end

  def self.replies_forwardee=(forwardee)
    $redis.set(:lyco_replies_forwardee, forwardee)
  end

end
