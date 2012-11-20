class UserProfilesController < ApplicationController
  expose(:user)

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

  def edit
    show
  end
end

