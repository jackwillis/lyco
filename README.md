# lyco

![Build status](https://travis-ci.org/jackwillis/lyco.svg?branch=master)

Ruby/Sinatra web app for sending SMS messages to multiple recipients (mass texting) using Twilio.

## Install

Download repository

    $ git clone git@github.com:jackwillis/lyco.git
    $ cd lyco
    $ bundle install

To make use of the auto-reply/forwarding feature, set your Twilio "Inbound Request Config" setting to `https://<your application url>/echo`.

Set up a redis instance.

## Usage

    $ TWILIO_ACCOUNT_SID=<your twilio account sid> \
      TWILIO_AUTH_TOKEN=<your twilio account sid> \
      TWILIO_SENDER=<your outgoing sms number> \
      HTTP_BASIC_USERNAME=<the global username for your instance> \
      HTTP_BASIC_PSASWORD=<the global password for your instance> \
      CANONICAL_HOST=<your domain name (optional)> \
      REDIS_URL=<your redis url> \
      rackup

## Testing

Testing is done with fakes, no environment variables needed.

    $ rspec
