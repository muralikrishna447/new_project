ActiveAdmin.register Activity, as: 'Publishing Schedule' do
  config.filters = false
  config.sort_order = ''
  config.batch_actions = false
  config.clear_action_items!

  menu priority: 2

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
        @activity.publishing_schedule.update_attributes!(params[:publishing_schedule][:publishing_schedule_attributes])
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
        suggested_dt = PublishingSchedule.maximum(:publish_at) + 1.day
        @activity.publishing_schedule = PublishingSchedule.new(publish_at: suggested_dt)
      end
    end
  end

  index title: 'Publishing Schedule' do
    column "Publish At" do |activity|
      if activity.publishing_schedule
        text =  activity.publishing_schedule.publish_at.localtime.strftime('%a %b %d, %Y %l:%M %p %Z')
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

  form do |f|
    f.inputs "#{f.object.title}", for: [:publishing_schedule, f.object.publishing_schedule] do |ps|
      ps.input :publish_at, as: :just_datetime_picker
    end
    f.actions
  end
end

