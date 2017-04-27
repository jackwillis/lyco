module Settings
  AUTOMATED_REPLY_FILENAME = File.join(".", "data", "reply.txt")
  REPLIES_FORWARDEE_FILENAME = File.join(".", "data", "forwardee.txt")

  DEFAULT_AUTOMATED_REPLY = <<~EOF
    Hello! You have received an automated text message.

    To unsubscribe, please reply STOP.
  EOF

  DEFAULT_REPLIES_FORWARDEE = "15005550006"

  def self.automated_reply
    if File.size?(AUTOMATED_REPLY_FILENAME)
      File.read(AUTOMATED_REPLY_FILENAME).strip
    else
      DEFAULT_AUTOMATED_REPLY
    end
  end

  def self.automated_reply=(reply)
    File.write(AUTOMATED_REPLY_FILENAME, reply.strip)
  end

  def self.replies_forwardee
    if File.size?(REPLIES_FORWARDEE_FILENAME)
      File.read(REPLIES_FORWARDEE_FILENAME).strip
    else
      DEFAULT_REPLIES_FORWARDEE
    end
  end

  def self.replies_forwardee=(forwardee)
    File.write(REPLIES_FORWARDEE_FILENAME, forwardee.strip)
  end

end

# Twilio makes a request to this URL when
# someone sends a text to our number
get "/echo" do
  from = params[:From]
  body = params[:Body]

  log = Logger.new(STDOUT)

  log.info("#{from} replied: #{body}")

  replies_forwardee = File.read(settings.replies_forwardee_filename).strip

  send_sms!(to: replies_forwardee, body: "#{from}'s reply: #{body}")

  log.info("#{from}'s message was forwarded to #{replies_forwardee}")

  content_type :xml

  response = Twilio::TwiML::Response.new do |r|
    r.Sms Settings.automated_reply
  end

  response.text
end

get "/settings" do
  @automated_reply = Settings.automated_reply
  @replies_forwardee = Settings.replies_forwardee 
  #File.read(settings.replies_forwardee_filename).strip

  erb :settings
end

post "/settings" do
  Settings.automated_reply = params[:automated_reply]
  Settings.replies_forwardee = params[:replies_forwardee]

  redirect "/settings"
end