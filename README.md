# lyco

Ruby/Sinatra web app for sending SMS messages to multiple recipients (mass texting) using Twilio.

## Install

Download repository

    $ git clone git@github.com:jackwillis/lyco.git
    $ cd lyco
    $ bundle install

Create a username/password combination (secret).

    $ ruby -r bcrypt -e 'puts BCrypt::Password.create("myusername:mypassword")'
    $2a$10$dClmhaZSc8vCMtc0V.MCV.6mTUy/v2kHrcazcW4LO90EzosJU.JKC

To make use of the auto-reply/forwarding feature, set your Twilio "Inbound Request Config" setting to `https://<your application url>/echo`.

Set up a redis instance.

## Usage

    $ TWILIO_ACCOUNT_SID=<your twilio account sid> \
      TWILIO_AUTH_TOKEN=<your twilio account sid> \
      TWILIO_SENDER=<your outgoing sms number> \
      LYCO_SECRET=<your username/password secret> \
      CANONICAL_HOST=<your domain name (optional)> \
      REDIS_URL=<your redis url> \
      rackup

## Testing

Testing is done with fakes, no environment variables needed.

    $ rspec