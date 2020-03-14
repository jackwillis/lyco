get "/settings" do
  @automated_reply = settings.db.automated_reply
  @replies_forwardee = settings.db.replies_forwardee 
  @autoreply_mode = settings.db.autoreply_mode?

  erb :settings
end

post "/settings" do
  reply = params[:automated_reply]&.normalize_newlines&.strip
  settings.db.automated_reply = reply

  forwardee = params[:replies_forwardee]&.normalize_newlines&.strip
  settings.db.replies_forwardee = forwardee

  autoreply_mode = params[:autoreply_mode] == 'on'
  settings.db.autoreply_mode = autoreply_mode

  redirect "/settings"
end
