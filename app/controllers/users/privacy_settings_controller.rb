class Users::PrivacySettingsController < ApplicationController
  def update
    if params['token'].blank?
      handle_invalid
      return
    end

    begin
      auth_token = AuthToken.from_string(params['token'])
    rescue JSON::JWS::VerificationFailed, JSON::JWT::InvalidFormat
      handle_invalid
      return
    end

    aa = ActorAddress.find_for_token(auth_token)
    if aa && aa.valid_token?(auth_token)
      user = User.find(aa.actor_id)
      info = {
        user_id: user.id,
        email: user.email,
        intent: params['intent']
      }
      Rails.logger.info "PRIVACY_OPTOUT #{info.to_json}"
    else
      handle_invalid
    end
  end

  def handle_invalid
    Rails.logger.info 'PRIVACY_OPTOUT_INVALID'
    render 'invalid'
  end
end
