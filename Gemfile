source "https://rubygems.org"

ruby "2.7.0"

gem "sinatra", "~> 2"
gem "sinatra-websocket", "~> 0.3"

# These gems are faked during testing (see spec/fakes.rb)
group :faked do
  gem "redis", "~> 4"
  gem "twilio-ruby", "~> 5"
end

group :test do
  gem "rspec", "~> 3"
  gem "rack-test", "~> 1"
  gem "rspec-html-matchers", "~> 0"
  gem "pry", "~> 0"
  gem "simplecov", "~> 0"
end
