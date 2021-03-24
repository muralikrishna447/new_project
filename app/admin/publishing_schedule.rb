ActiveAdmin.register Activity, as: 'Publishing Schedule' do
  config.filters = false
  config.sort_order = ''
  config.batch_actions = false
  config.clear_action_items!

  menu priority: 2

  form partial: 'form'


  controller do
    def scoped_collection
      Activity
        .chefsteps_generated
        .where("title <> ''")
        .where(published: false)
        .joins('LEFT OUTER JOIN publishing_schedules ON activities.id = publishing_schedules.activity_id')
        .order("COALESCE(publishing_schedules.publish_at, activities.updated_at) DESC")
    end

    def update
      @activity = Activity.find(params[:id])
      begin
        publishing_schedule = PublishingSchedule.find_or_initialize_by(activity_id: @activity.id)
        publishing_schedule.active = true
        publishing_schedule.assign_attributes(publishing_schedule_params)
        publishing_schedule.save!
        redirect_to admin_publishing_schedules_path
        return
      rescue Exception => e
        flash[:error] = e.message
        redirect_to edit_admin_publishing_schedule_path(@activity)
      end
    end

    def edit
      @activity = Activity.includes(:publishing_schedule).find(params[:id])
      if ! @activity.publishing_schedule
        suggested_dt = DateTime.now + 1.day
        @activity.build_publishing_schedule(publish_at: suggested_dt)
      end
    end

    def destroy
      activity = Activity.includes(:publishing_schedule).find(params[:id])
      activity.publishing_schedule.try(:destroy)
      flash[:notice] = "Schedule removed for \"#{activity.title}\""
      redirect_to admin_publishing_schedules_path
    end

    private

    def publishing_schedule_params
      params[:activity].require(:publishing_schedule_attributes).permit(:publish_at_pacific)
    end
  end

  action_item :view, only: [:edit] do
    link_to 'Remove Schedule', admin_publishing_schedule_path(activity), method: :delete
  end

  index title: 'Publishing Schedule' do
    column "Publish At" do |activity|
      if activity.publishing_schedule
        text =  activity.publishing_schedule.publish_at.in_time_zone(Rails.application.config.chefsteps_timezone).strftime('%a %b %d, %Y %l:%M %p %Z')
        link_to(text, edit_admin_publishing_schedule_path(activity))
      else
        link_to("Schedule...", edit_admin_publishing_schedule_path(activity))
      end
    end

    column :premium do |activity|
      activity.premium? ? status_tag('PREMIUM') : ""
    end

    column :title, sortable: :title do |activity|
      link_to activity.title.html_safe, activity_path(activity), target: '_blank'
    end
  end
end

