class FakeSMSClient
  attr_reader :delivered

  def initialize
    reset!
  end

  def account
    self
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
