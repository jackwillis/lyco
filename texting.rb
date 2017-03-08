def process_texts(params)
  10.times do |n|
    yield "Processing text #{n}\n"
    sleep rand*rand*rand
  end

  yield "Done\n"
end