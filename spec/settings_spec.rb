require_relative "spec_helper"

describe "settings controller" do

  it "displays settings page" do
    use_credentials
    get "/settings"

    expect(last_response.body).to include("Automated reply message")
  end

end