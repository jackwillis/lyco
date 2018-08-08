require_relative 'spec_helper'

describe 'settings controller' do

  it 'displays settings page', with_db: true do
    get '/settings'

    expect(last_response.body).to include('Automated reply message')
    expect(last_response.body).to have_tag('textarea#automated_reply', text: db.automated_reply)
    expect(last_response.body).to have_tag('input#replies_forwardee', with: { value: db.replies_forwardee })
  end

  it 'changes nothing when posting with no params', with_db: true do
    expect { post '/settings', {} }.to_not change { db.state }
  end

  it 'updates the database state', with_db: true do
    params = { automated_reply: 'foo', replies_forwardee: 'bar' }

    post '/settings', params

    expect(db.state).to eq(params)
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

  it 'rejects invalid requests to the echo hook', with_sms: true do
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
