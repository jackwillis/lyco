# Lyco

Lyco is a Ruby/Sinatra web app for sending SMS messages to multiple recipients (mass texting).
It is specific to the SMS provider Twilio.

![Build status](https://travis-ci.org/jackwillis/lyco.svg?branch=master)

## Install

1. Download repository and install gem bundle

        $ git clone git@github.com:jackwillis/lyco.git
        $ cd lyco
        $ bundle install

2. Set up a Redis server.

## Usage

1. Start the web server with proper environment variables

        $ TWILIO_ACCOUNT_SID=<your twilio account sid> \
          TWILIO_AUTH_TOKEN=<your twilio account sid> \
          TWILIO_SENDER=<your outgoing sms number> \
          HTTP_BASIC_USERNAME=<the global username for your instance> \
          HTTP_BASIC_PASSWORD=<the global password for your instance> \
          REDIS_URL=<your redis url> \
          rackup

2. To make use of the auto-reply/forwarding feature,
set your Twilio "Inbound Request Config" setting to `<your application url>` + `/echo`.

## Testing

Testing is done with fakes, no environment variables are needed here.

        $ rspec
