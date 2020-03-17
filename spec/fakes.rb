# Fakes the Twilio REST client:
#
# > c = FakeTwilioRESTClient.new
# REPLACES
# > c = Twilio::REST::Client.new(account_sid, auth_token)
#
# SO YOU CAN DO
# > c.messages.create(from: a, to: b, body: c)
#
# THEN ALSO
# > c.delivered
#=> [{ from: a, to: b, body: c }]

class FakeTwilioRESTClient
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
# > r = FakeRedis.new
# REPLACES
# > r = Redis.new
#
# THEN
# > r.set('foo', 'bar')
#=> 'bar'
# > r.get('foo')
#=> 'bar'
# > r.get('baz')
#=> nil

class FakeRedis
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
