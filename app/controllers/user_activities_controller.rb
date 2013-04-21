class UserActivitiesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @user_activity = UserActivity.new(params[:user_activity])
    @user_activity.action = 'Cooked'
    @user_activity.user_id = current_user.id
    if @user_activity.save
      redirect_to @user_activity.activity, notice: "Woohoo! Hope you enjoyed making the #{@user_activity.activity.title}!"
    else
      flash[:error] = 'Sorry, no spam allowed.'
      redirect_to activity_path(@user_activity.activity)
    end
  end
end