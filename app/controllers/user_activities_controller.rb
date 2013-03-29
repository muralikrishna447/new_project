class UserActivitiesController < ApplicationController
  def create
    @user_activity = UserActivity.new(params[:user_activity])
    @user_activity.action = 'Cooked'
    @user_activity.user_id = current_user.id
    if @user_activity.save
      redirect_to @user_activity.activity, notice: 'Yay!'
    else
      render @user_activity.activity
    end
  end
end