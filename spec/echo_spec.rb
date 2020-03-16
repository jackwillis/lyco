require_relative 'spec_helper'

describe 'echo controller controller' do
  echo_path = '/echo'

  it 'forwards incoming messages to the replies forwardee', with_sms: true do
    get echo_path, { From: '15551234567', Body: 'thanks!' }

    expect(sms_client.delivered).to eq([{
      from: sender, to: db.replies_forwardee, body: '15551234567\'s reply: thanks!'
    }])
  end

  it 'rejects invalid requests to the echo hook', with_sms: true do
    params_examples = [
        {},
        { From: '15551234567' },
        { Body: 'test' }
    ]
  end

  it 'sends auto replies', with_db: true do
    db.autoreply_mode = true

    get '/echo', { From: '15551234567', Body: 'test' }

    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Message>#{db.automated_reply}</Message>\n</Response>\n"

    expect(last_response.body).to eq(xml)
  end

  it 'only sends autoreplies when autoreply mode is on', with_db: true do
    db.autoreply_mode = false

    get '/echo', { From: '15551234567', Body: 'test' }

    expect(last_response.status).to be(204)
  end

  it 'rejects invalid requests to the echo hook', with_db: true do
    db.autoreply_mode = true    

    params_examples = [
        {},
        { From: '15551234567' },
        { Body: 'test' }
    ]
    params_examples.each do |params|
      get echo_path, params
      expect(last_response.status).to be(400)
    end
  end

  it 'sends the automated response to the replier' do
    get echo_path, { From: '15551234567', Body: 'thanks!' }

    expect(last_response.body).to have_tag(:response) do
      with_tag :message, text: db.automated_reply
    end
  end

end