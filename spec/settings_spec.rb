require_relative 'spec_helper'

describe 'settings controller' do

  it 'displays settings page', with_db: true do
    get '/settings'

    expect(last_response.body).to include('Automated reply message')
    expect(last_response.body).to have_tag('textarea#automated_reply', text: db.automated_reply)
    expect(last_response.body).to have_tag('input#replies_forwardee', with: { value: db.replies_forwardee })
  end

  it 'changes nothing when posting with no params', with_db: true do
    before_state = db.state

    post '/settings', {}

    expect(db.state).to eq(before_state)
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

end