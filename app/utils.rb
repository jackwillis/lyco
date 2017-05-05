class String
  def normalize_newlines
    encode(encoding, universal_newline: true)
  end
end

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