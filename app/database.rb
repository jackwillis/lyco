class DatabaseService
  DEFAULT_AUTOMATED_REPLY = <<~EOF
    Hello! You have received an automated text message.

    To unsubscribe, please reply STOP
  EOF

  DEFAULT_REPLIES_FORWARDEE = '15005550006'

  DEFAULT_AUTOREPLY_MODE = true

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

  def replies_forwardee=(forwardee)
    @redis.set(:lyco_replies_forwardee, forwardee)
  end

  def autoreply_mode?
    case @redis.get(:lyco_autoreply_mode)
    when nil
      DEFAULT_AUTOREPLY_MODE
    when 'true'
      true
    else
      false
    end
  end

  def autoreply_mode=(state)
    raise ArgumentError, 'state must be boolean' \
      unless state == !!state

    @redis.set(:lyco_autoreply_mode, state.to_s)
  end

  def state
    {
      automated_reply: automated_reply,
      replies_forwardee: replies_forwardee,
      autoreply_mode: autoreply_mode?
    }
  end

  def reset!
    self.automated_reply = DEFAULT_AUTOMATED_REPLY
    self.replies_forwardee = DEFAULT_REPLIES_FORWARDEE
    self.autoreply_mode = DEFAULT_AUTOREPLY_MODE
  end

end

set :db, DatabaseService.new(settings.redis)
