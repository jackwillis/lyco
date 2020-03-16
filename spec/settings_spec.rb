require_relative 'spec_helper'

describe 'settings controller' do

  describe 'the settings action' do
    settings_path = '/settings'

    it 'does not change the String database values when given no params', with_db: true do
      expect { post settings_path, {} }.to_not change {
        [db.automated_reply, db.replies_forwardee]
      }
    end

    it 'sets the Boolean database value to false when given no params', with_db: true do
      db.autoreply_mode = true
      expect { post settings_path, {} }.to change { db.autoreply_mode? }
    end

    it 'sets the Boolean database value to true when given value "on"', with_db: true do
      db.autoreply_mode = false
      expect { post settings_path, { autoreply_mode: 'on' } }.to change { db.autoreply_mode? }
    end

    it 'sets String database values properly', with_db: true do
      post '/settings', { automated_reply: 'foo', replies_forwardee: 'bar' }

      expect([db.automated_reply, db.replies_forwardee]).to eq ['foo', 'bar']
    end

    it 'displays the current settings', with_db: true do
      get settings_path

      expect(last_response.body).to include('Automated reply message')
      expect(last_response.body).to have_tag('input#autoreply_mode', with: { type: 'checkbox' })
      expect(last_response.body).to have_tag('textarea#automated_reply', text: db.automated_reply)
      expect(last_response.body).to have_tag('input#replies_forwardee', with: { value: db.replies_forwardee })
    end

    it 'changes nothing when posting with no params', with_db: true do
      expect { post settings_path, {} }.to_not change { db.state }
    end

    it 'updates the database state', with_db: true do
      post settings_path, { automated_reply: 'foo', replies_forwardee: 'bar', autoreply_mode: 'off' }

      expect(db.state).to eq({ automated_reply: 'foo', replies_forwardee: 'bar', autoreply_mode: false })
    end

    it 'redirects to the settings page after posting', with_db: true do
      params_examples = [
          {},
          { invalid: 'yes' },
          { automated_reply: 'foo' },
          { automated_reply: 'foo', replies_forwardee: 'bar' }
      ]

      params_examples.each do |params|
        post settings_path, params

        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq(settings_path)
      end
    end

  end

  describe 'the echo action' do
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

end

