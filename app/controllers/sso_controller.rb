require "js_connect"

class SsoController < ApplicationController
  before_action :authenticate_cors_user

  def index
    # 1. Get your client ID and secret here. These must match those in your jsConnect settings.
    client_id = "1924714588"
    secret = "7ba99d277305511571d4b0ef843daa4c"


    # 3. Fill in the user information in a way that Vanilla can understand.
    user = {}

    if user_signed_in?
       # CHANGE THESE FOUR LINES.
       user["uniqueid"] = current_user.id.to_s
       user["name"] = current_user.name
       user["email"] = current_user.email
       user["photourl"] = current_user_presenter.profile_image_url
    end

    # 4. Generate the jsConnect string.
    secure = true # this should be true unless you are testing.
    json = JsConnect.getJsConnectString(user, self.params, client_id, secret, secure)

    render :text => json
  end

end
