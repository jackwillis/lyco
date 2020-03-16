# Lyco

Lyco a.k.a. MassTextMachine is a web app for sending SMS messages to a large batch of recipients (mass texting).

It requires the Ruby programming language, a Redis database, and an account with the SMS provider Twilio.
On the server, it uses the Sinatra web framework, and in the browser, it uses jQuery.

![Build status](https://travis-ci.org/jackwillis/lyco.svg?branch=master)

## Local installation

1. [Download](https://www.ruby-lang.org/en/downloads/) or check (`ruby -v`) for Ruby 2.3 or greater.

2. [Set up](https://redis.io/topics/quickstart) or provision a Redis server.

3. Download this repository and install the RubyGem bundle.

```
git clone git@github.com:jackwillis/lyco.git
cd lyco
bundle install
```

## Usage

1. Set up the environment variables:

Name | Description
--- | ---
`TWILIO_ACCOUNT_SID` | Twilio Account SID
`TWILIO_AUTH_TOKEN` | [Twilio Auth Token](https://support.twilio.com/hc/en-us/articles/223136027-Auth-Tokens-and-How-to-Change-Them)
`TWILIO_SENDER` | Twilio phone number
`HTTP_BASIC_USERNAME` | [HTTP Basic Auth](https://demo.twilio.com/welcome/sms/) username for your lyco instance (this is a single-user app)
`HTTP_BASIC_PASSWORD` | HTTP Basic Auth password
`REDIS_URL` | URL of your Redis instance, e.g. `redis://127.0.0.1:6379`
`INSTANCE_NAME` | (optional) The name of your instance, e.g. `My Great Organization`

2. Start the web server with `bundle exec rackup`.

3. To make use of the auto-reply/forwarding feature,
make sure your web server is publicly accessible and using HTTPS.  
Set your Twilio "Inbound Request Config" setting to `https://` + `<username>` + `:` + `<password>` + `@` + `<host>` + `/echo`.

## Testing

RSpec tests cover most of the server code.

```
bundle exec rspec
```

## Browser support

Lyco works on all current web browsers.
Viewing the activity logs requires Javascript.

## Goals

* Re-do activity logging
  * Store activity logs in a database
  * Use AJAX polling to update activity log view
  * Get rid of dependency on sinatra-websocket
* Change unsubscribe behavior
  * Don't forward `STOP` messages
  * Store list of unsubscribed users in a database
  * Don't try to send messages to unsubscribed users (wastes money)
* Get rid of dependency on jQuery
* Write full RSpec coverage and tests for JS
* Improve authentication

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

### Copyright

Copyleft 🄯 2017–2020 Jack Willis

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but **without any warranty**; without even the implied warranty of
**merchantability** or **fitness for a particular purpose**.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.