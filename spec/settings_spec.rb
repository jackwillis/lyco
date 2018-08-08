require_relative 'spec_helper'

describe 'settings controller' do

  it 'displays settings page', with_db: true do
    get '/settings'

    expect(last_response.body).to include('Automated reply message')
    expect(last_response.body).to have_tag('input#autoreply_mode', with: { type: 'checkbox' })
    expect(last_response.body).to have_tag('textarea#automated_reply', text: db.automated_reply)
    expect(last_response.body).to have_tag('input#replies_forwardee', with: { value: db.replies_forwardee })
  end

  it 'does not change the String database values when given no params', with_db: true do
    expect { post '/settings', {} }.to_not change {
      [db.automated_reply, db.replies_forwardee]
    }
  end

  it 'sets the Boolean database value to false when given no params', with_db: true do
    db.autoreply_mode = true
    expect { post '/settings', {} }.to change { db.autoreply_mode? }
  end

  it 'sets the Boolean database value to true when given value "on"', with_db: true do
    db.autoreply_mode = false
    expect { post '/settings', { autoreply_mode: "on" } }.to change { db.autoreply_mode? }
  end

  it 'sets String database values properly', with_db: true do
    post '/settings', { automated_reply: 'foo', replies_forwardee: 'bar' }

    expect([db.automated_reply, db.replies_forwardee]).to eq ['foo', 'bar']
  end

  it 'redirects to the settings page after posting', with_db: true do
    params_examples = [
        {},
        { invalid: 'yes' },
        { automated_reply: 'foo' },
        { automated_reply: 'foo', replies_forwardee: 'bar' }
    ]

    params_examples.each do |params|
      post '/settings', params

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/settings')
    end
  end

  it 'forwards incoming messages to the replies forwardee', with_sms: true do
    get '/echo', { From: '15551234567', Body: 'thanks!' }

    expect(sms_client.delivered).to eq([{
      from: sender, to: db.replies_forwardee, body: '15551234567\'s reply: thanks!'
    }])
  end

  it 'sends auto replies', with_db: true do
    db.autoreply_mode = true

    get '/echo', { From: '15551234567', Body: 'test' }

    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Sms>#{db.automated_reply}</Sms></Response>"

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
      get '/echo', params
      expect(last_response.status).to be(400)
    end
  end

end
