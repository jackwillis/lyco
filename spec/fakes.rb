# Fakes the Twilio REST client:
#
# > c = Twilio::REST::Client.new(account_sid, auth_token)
# OR
# > c = FakeSMSClient.new
#
# > c.messages.create(from: a, to: b, body: c)
#
# THEN ALSO
# > c.delivered
#=> [{ from: a, to: b, body: c }]

class FakeSMSClient
  attr_reader :delivered

  def initialize
    reset!
  end

  def messages
    self
  end

  def create(message)
    @delivered << message
  end

  def reset!
    @delivered = []
  end
end

# Fakes the Redis class:
#
# > r = Redis.new
# OR
# > r = FakeRedisClient.new
# 
# > r.set('foo', 'bar')
#=> 'bar'
# > r.get('foo')
#=> 'bar'
# > r.get('baz')
#=> nil

class FakeRedisClient
  def initialize
    @data = {}
  end

  def get(key)
    @data[key]
  end

  def set(key, value)
    @data[key] = value
  end
end
