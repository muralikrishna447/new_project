class Users::PrivacySettingsController < ApplicationController
  INTENTS = %w(confirm_opt_out decline_opt_out).freeze

  def update
    if params['token'].blank? || params['intent'].blank? || !INTENTS.include?(params['intent'])
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
    if aa && aa.valid_token?(auth_token, 0, OptOutIntentSender::TOKEN_RESTRICTION)
      user = User.find(aa.actor_id)
      unless user
        handle_invalid
        return
      end

      info = {
        user_id: user.id,
        email: user.email,
        intent: params['intent'],
        timestamp: Time.now.utc.iso8601
      }
      Rails.logger.error "PRIVACY_OPTOUT #{info.to_json}"
    else
      handle_invalid
    end
  end

  def handle_invalid
    Rails.logger.warn 'PRIVACY_OPTOUT_INVALID'
    render 'invalid'
  end
end
