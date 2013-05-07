class UserProfilesController < ApplicationController
  # expose(:user)
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
    @categories = Forum.categories
    @discussions = Forum.discussions.take(4)
    @user = User.find(params[:id])
    @recipes = Activity.published.recipes.last(6)
    @techniques = Activity.published.techniques.last(6)
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
    # if user.present?
    #   if user.update_whitelist_attributes(params[:user_profile])
    #     render json: user_presenter.present
    #   else
    #     render_errors(user)
    #   end
    # else
    #   render_resource_not_found
    # end
  end
end

