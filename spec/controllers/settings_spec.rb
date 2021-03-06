require_relative '../spec_helper'

describe 'settings controller' do
  settings_path = '/settings'

  it 'does not change the String database values when given no params', with_db: true do
    expect { post settings_path, {} }.to_not change {
      [settings_db.automated_reply, settings_db.replies_forwardee]
    }
  end

  it 'sets the Boolean database value to false when given no params', with_db: true do
    settings_db.autoreply_mode = true
    expect { post settings_path, {} }.to change { settings_db.autoreply_mode? }
  end

  it 'sets the Boolean database value to true when given value "on"', with_db: true do
    settings_db.autoreply_mode = false
    expect { post settings_path, { autoreply_mode: 'on' } }.to change { settings_db.autoreply_mode? }
  end

  it 'sets String database values properly', with_db: true do
    post '/settings', { automated_reply: 'foo', replies_forwardee: 'bar' }

    expect([settings_db.automated_reply, settings_db.replies_forwardee]).to eq ['foo', 'bar']
  end

  it 'displays the current settings', with_db: true do
    get settings_path

    expect(last_response.body).to include('Automated reply message')
    expect(last_response.body).to have_tag('input#autoreply_mode', with: { type: 'checkbox' })
    expect(last_response.body).to have_tag('textarea#automated_reply', text: settings_db.automated_reply)
    expect(last_response.body).to have_tag('input#replies_forwardee', with: { value: settings_db.replies_forwardee })
  end

  it 'changes nothing when posting with no params', with_db: true do
    expect { post settings_path, {} }.to_not change { settings_db.state }
  end

  it 'updates the database state', with_db: true do
    post settings_path, { automated_reply: 'foo', replies_forwardee: 'bar', autoreply_mode: 'off' }

    expect(settings_db.state).to eq({ automated_reply: 'foo', replies_forwardee: 'bar', autoreply_mode: false })
  end

  it 'redirects to the settings page after posting', with_db: true do
    [
      {},
      { invalid: 'yes' },
      { automated_reply: 'foo' },
      { automated_reply: 'foo', replies_forwardee: 'bar' }
    ].each do |params|
      post settings_path, params

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq(settings_path)
    end
  end
end
