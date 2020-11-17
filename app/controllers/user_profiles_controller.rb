class UserProfilesController < ApplicationController
  expose(:encourage_profile) { Copy.find_by_location('encourage-profile') }
  expose(:user_presenter) { UserPresenter.new(user)}
  before_action :load_user, only: [:edit, :update, :marketing_subscription]

  TIMELINE_EVENT_LIMIT = 50

  def show
    if params[:id] == 'self'
      if ! current_user
        redirect_to sign_in_url
      else
        redirect_to user_profile_path(current_user)
      end
      return
    end
    @user = User.friendly.find(params[:id])
    # @courses = Course.published
    @is_current_user =  (@user == current_user)
    @user_pubbed_recipes = @user.created_activities.published
    @user_unpubbed_recipes = ((current_user && current_user.admin?) || @is_current_user) ? @user.created_activities.unpublished : []
    @total_recipes = @user_pubbed_recipes.count + @user_unpubbed_recipes.count
    @can_add_recipes = (can? :create, Activity) && @is_current_user
    @show_recipes_tab = (@total_recipes > 0) || (@can_add_recipes)
    @timeline_events =  @user.events.where("trackable_type IN ('Activity','Comment', 'Ingredient','Like','Upload')").includes([:user, :trackable]).limit(TIMELINE_EVENT_LIMIT).timeline.find_all { |e| e.trackable.published rescue true }

    @user.events.timeline.unviewed.each do |event|
      event.viewed = true
      event.save
    end
  end

  def edit
    render_unauthorized unless current_user == @user
  end

  def update
    email_before_update = @user.email
    return render_unauthorized unless current_user == @user
    if @user.update_attributes(user_params)
      email_after_update = @user.email
      Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], @user.id)
      if email_after_update != email_before_update
        Rails.logger.info "Email change detected - enqueuing EmailUpdate job"
        Resque.enqueue(EmailUpdate, @user.id, email_before_update, email_after_update)
      end
      redirect_to user_profile_path(@user), notice: 'User profile updated!'
    else
      render 'edit'
    end
  end

  def marketing_subscription
    # To avoid the multiple tab issue, checking current user marketing mail status and request marketing mail status
    if @user.marketing_mail_status == params[:user][:marketing_mail_status]
      if @user.subscribed?
        unsubscribe_from_mailchimp(@user)
      else
        email_list_signup(@user, 'profile_page')
      end
    end
    redirect_to user_profile_path(@user), notice: 'User profile updated!'
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation,:remember_me,
                                 :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities,
                                 :signed_up_from, :bio, :image_id, :referred_from, :referrer_id,
                                 :survey_results, :events_count)
  end
end
