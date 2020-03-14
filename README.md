# Lyco

Lyco is a web app for sending SMS messages to a large batch of recipients (mass texting).
It is specific to the SMS provider Twilio.
It is built with the Ruby programming language and the Sinatra web framework.

![Build status](https://travis-ci.org/jackwillis/lyco.svg?branch=master)

## Install

1. Download the repository and install the RubyGem bundle.

```
git clone git@github.com:jackwillis/lyco.git
cd lyco
bundle install
```

2. [Set up a Redis server.](https://redis.io/topics/quickstart)

## Usage

1. Start the web server with proper environment variables:

```
TWILIO_ACCOUNT_SID=<your twilio account sid> \
TWILIO_AUTH_TOKEN=<your twilio account sid> \
TWILIO_SENDER=<your outgoing sms number> \
HTTP_BASIC_USERNAME=<the global username for your instance> \
HTTP_BASIC_PASSWORD=<the global password for your instance> \
REDIS_URL=<your redis url> \
bundle exec rackup
```

2. To make use of the auto-reply/forwarding feature,
make sure your web server is publicly accessible
and that HTTP Basic Authentication is configured.
Set your Twilio "Inbound Request Config" setting to `https://` + `<username>` + `:` + `<password>` + `@` + `<host>` + `/echo`.


## Testing

RSpec tests cover most of the server code.

```
bundle exec rspec
```

## Dependencies and licenses

Name | via | License
--- | --- | ---
[Ruby](https://www.ruby-lang.org/) | | [BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause)
[Sinatra](http://sinatrarb.com/) | [Gemfile](Gemfile) | [MIT](https://opensource.org/licenses/MIT)
[Redis](https://redis.io/) | | [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause)
[redis-rb](https://github.com/redis/redis-rb) | [Gemfile](Gemfile) | [MIT](https://opensource.org/licenses/MIT)
[twilio-ruby](https://www.twilio.com/docs/libraries/ruby) | [Gemfile](Gemfile) | [MIT](https://opensource.org/licenses/MIT)
[jQuery](https://jquery.com/) | [app/assets/jquery-3.4.1.min.js](app/assets/jquery-3.4.1.min.js) | [MIT](https://opensource.org/licenses/MIT)
[Pure CSS](https://purecss.io/) | [app/assets/pure.min.css](app/assets/pure.min.css) | [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause)
[sinatra-websocket](https://github.com/gruis/sinatra-websocket) | [Gemfile](Gemfile) | [MIT](https://opensource.org/licenses/MIT)

This is free software licensed under the terms of the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0), version 3 or later.

© Copyright Jack Willis 2017–2020

## Goals

* Get rid of dependency on `sinatra-websocket`