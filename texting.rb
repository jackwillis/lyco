$log = Logger.new(STDOUT)

def process_texts(params)
  $log.info "sending texts"

  10.times do |n|
    yield "Processing text #{n}\n"
    sleep rand*rand*rand
  end

  yield "Done\n"
end