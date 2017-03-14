require "twilio-ruby"
require "logger"

def send_sms!(to:, body:)
  @_client ||= Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
  @_client.account.messages.create(from: SENDER, to: to, body: body)
end  

def normalize_number(number)
  number.gsub(/\D/, "")
end

def parse_contacts(numbers_string)
  numbers_string
    .split("\n")
    .map { |c| normalize_number(c) }
    .reject(&:empty?)
    .uniq
end

def process_texts(params)
  log = Logger.new(STDOUT)

  contacts = parse_contacts(params[:numbers])
  message_parts = params[:message].map(&:strip).reject(&:empty?)

  begin_msg = "Sending a #{message_parts.length}-part " +
    "message to #{contacts.length} contacts"

  log.info(begin_msg)
  yield begin_msg + "\n"

  num_contacted = 0
  num_errors = 0

  contacts.each do |contact|
    begin
      yield "Sending message to #{contact}"

      message_parts.each_with_index do |part, i|
        send_sms!(to: contact, body: part)
        yield " (part #{i + 1})"
      end

      yield " [OK]\n"

      num_contacted += 1
    rescue => e
      num_errors += 1

      yield " [Error] #{e.message}\n"
    end
  end

  yield "Done. Sent #{num_contacted} messages, #{num_errors} errors.\n"
end
