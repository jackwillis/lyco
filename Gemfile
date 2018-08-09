source "https://rubygems.org"

ruby "2.5.0"

gem "sinatra", "~> 2.0.3"
gem "sinatra-websocket", "~> 0.3.1"
gem "bcrypt", "~> 3.1.12"
gem "rack-canonical-host", "~> 0.2.3"

group :mocked do
  gem "redis", "~> 4.0.1"
  gem "twilio-ruby", "~> 5.12.0"
end

group :test do
  gem "rspec", "~> 3.8.0"
  gem "rack-test", "~> 1.1.0"
  gem "rspec-html-matchers", ">= 0.9.1"
  gem "pry", ">= 0.11.3"
end
