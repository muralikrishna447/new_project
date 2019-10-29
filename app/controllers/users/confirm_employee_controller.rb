class Users::ConfirmEmployeeController < ApplicationController

  def confirm
    begin
      auth_token = AuthToken.from_string(params['token'])
    rescue JSON::JWS::VerificationFailed, JSON::JWT::InvalidFormat
      handle_invalid
      return
    end

    aa = ActorAddress.find_for_token(auth_token)
    if aa && aa.valid_token?(auth_token, 0, EmployeeAccountProcessor::TOKEN_RESTRICTION)
      user = User.find(aa.actor_id)
      unless user
        handle_invalid
        return
      end

      # Ideally we would do this in a background job, but it should be fast
      # and we shouldn't get too many of these requests.
      Rails.logger.info("Granting employee subscriptions to user with ID #{user.id}")
      Subscriptions::ChargebeeUtils.grant_employee_subscriptions(user.id, user.email)

      # Right now it makes most sense to redirect to the Studio Pass page,
      # which will cause a full page load and the employee should get the subscribed UX.
      redirect_to "https://www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}/studiopass"
    else
      handle_invalid
    end
  end

  def handle_invalid
    Rails.logger.info "ConfirmEmployeeController invalid token"
    render 'invalid'
  end
end
