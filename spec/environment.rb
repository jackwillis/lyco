# Fake environment variables
set :sms_client, FakeTwilioRESTClient.new
set :log, Logger.new(StringIO.new)
set :redis, FakeRedis.new
set :username, 'foo'
set :password, 'bar'
set :sender, '15005550006'
