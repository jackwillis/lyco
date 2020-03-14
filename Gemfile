source "https://rubygems.org"

ruby "2.7.0"

gem "sinatra", "~> 2.0.3"
gem "sinatra-websocket", "~> 0.3.1"

# These gems are faked during testing (see spec/fakes.rb)
group :faked do
  gem "redis", "~> 4.0.1"
  gem "twilio-ruby", "~> 5.12.0"
end

group :test do
  gem "rspec", "~> 3.8.0"
  gem "rack-test", "~> 1.1.0"
  gem "rspec-html-matchers", ">= 0.9.1"
  gem "pry", ">= 0.11.3"
end
