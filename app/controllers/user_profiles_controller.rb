class UserProfilesController < ApplicationController
  expose(:user)
  expose(:encourage_profile) { Copy.find_by_location('encourage-profile') }
  expose(:user_presenter) { UserPresenter.new(user)}

  def update
    render_unauthorized unless current_user == user
    if user.present?
      if user.update_attributes(params[:user_profile])
        render json: user
      else
        render_errors(user)
      end
    else
      render_resource_not_found
    end
  end
end

