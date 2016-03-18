class UserProfilesController < ApplicationController
  expose(:encourage_profile) { Copy.find_by_location('encourage-profile') }
  expose(:user_presenter) { UserPresenter.new(user)}

  def show
    if params[:id] == 'self'
      if ! current_user
        redirect_to sign_in_url
      else
        redirect_to user_profile_path(current_user)
      end
      return
    end
    @user = User.find(params[:id])
    # @courses = Course.published
    @is_current_user =  (@user == current_user)
    @user_pubbed_recipes = @user.created_activities.published
    @user_unpubbed_recipes = ((current_user && current_user.admin?) || @is_current_user) ? @user.created_activities.unpublished : []
    @total_recipes = @user_pubbed_recipes.count + @user_unpubbed_recipes.count
    @can_add_recipes = (can? :create, Activity) && @is_current_user
    @show_recipes_tab = (@total_recipes > 0) || (@can_add_recipes)
    @timeline_events =  @user.events.timeline.find_all { |e| e.trackable.published rescue true }
    @timeline_events =  @timeline_events.reject { |e| e.trackable_type == 'Vote'}

    @user.events.timeline.unviewed.each do |event|
      event.viewed = true
      event.save
    end
  end

  def edit
    @user = User.find(params[:id])
    render_unauthorized unless current_user == @user
  end

  def update
    @user = User.find(params[:id])
    render_unauthorized unless current_user == @user
    if @user.update_attributes(params[:user])
      Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], @user.id)
      redirect_to user_profile_path(@user), notice: 'User profile updated!'
    else
      render 'edit'
    end
  end
end
