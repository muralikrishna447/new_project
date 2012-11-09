class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    assign_from_unconfirmed_user

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  private

  def assign_from_unconfirmed_user
    unconfirmed_user = session["devise.unconfirmed_user"]
    self.resource.assign_attributes({
      provider: unconfirmed_user.provider,
      uid: unconfirmed_user.uid,
      password: Devise.friendly_token[0,20]
    }, without_protection: true) if unconfirmed_user
  end
end
