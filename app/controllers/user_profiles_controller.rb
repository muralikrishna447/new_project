class UserProfilesController < ApplicationController
  expose(:encourage_profile) { Copy.find_by_location('encourage-profile') }
  expose(:user_presenter) { UserPresenter.new(user)}
  expose(:started_quizzes) {
    Quiz.joins(:quiz_sessions).where(quiz_sessions: { user_id: current_user.id, completed: false })
  }

  expose(:completed_quizzes) {
    Quiz.joins(:quiz_sessions).where(quiz_sessions: { user_id: current_user.id, completed: true })
  }

  expose(:quiz_count) { started_quizzes.count + completed_quizzes.count }

  def show
    @user = User.find(params[:id])
    @courses = Course.published
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    render_unauthorized unless current_user == @user
    if @user.update_attributes(params[:user])
      redirect_to user_profile_path(@user), notice: 'User profile updated!'
    else
      render 'edit'
    end
  end
end

