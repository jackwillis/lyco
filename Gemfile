source "https://rubygems.org"

ruby "2.5.0"

gem "sinatra", "~> 1.4.8"
gem "sinatra-websocket", "~> 0.3.1"
gem "bcrypt", "~> 3.1.11"
gem "rack-canonical-host", "~> 0.2.2"

group :mocked do
  gem "redis", "~> 3.3.3"
  gem "twilio-ruby", "~> 4.13.0"
end

group :test do
  gem "rspec", "~> 3.3.0"
  gem "rack-test", "~> 0.6.3"
  gem "rspec-html-matchers", ">= 0.9.1"
  gem "pry", ">= 0.10.4"
end
