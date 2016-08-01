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
        @activity.publishing_schedule.update_attributes!(params[:activity][:publishing_schedule_attributes])
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
        @activity.publishing_schedule = PublishingSchedule.new(publish_at: suggested_dt)
      end
    end

    def destroy
      activity = Activity.includes(:publishing_schedule).find(params[:id])
      activity.publishing_schedule.destroy
      flash[:notice] = "Schedule removed for \"#{activity.title}\""
      redirect_to admin_publishing_schedules_path
    end
  end

  action_item only: :edit do
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
      activity.premium? ? status_tag( "PREMIUM", :ok ) : ""
    end

    column :title, sortable: :title do |activity|
      link_to activity.title.html_safe, activity_path(activity), target: '_blank'
    end
  end
end

