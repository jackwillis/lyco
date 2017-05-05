class DatabaseService
  DEFAULT_AUTOMATED_REPLY = <<~EOF
    Hello! You have received an automated text message.

    To unsubscribe, please reply STOP.
  EOF

  DEFAULT_REPLIES_FORWARDEE = "15005550006"

  def initialize(redis)
    @redis = redis
  end

  def automated_reply
    @redis.get(:lyco_automatic_reply) || DEFAULT_AUTOMATED_REPLY
  end

  def automated_reply=(reply)
    @redis.set(:lyco_automatic_reply, reply)
  end

  def replies_forwardee
    @redis.get(:lyco_replies_forwardee) || DEFAULT_REPLIES_FORWARDEE
  end

  def self.replies_forwardee=(forwardee)
    @redis.set(:lyco_replies_forwardee, forwardee)
  end

end

set :db, DatabaseService.new(settings.redis)