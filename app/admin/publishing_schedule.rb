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
  end

  index title: 'Publishing Schedule' do
    column :premium do |activity|
      activity.premium? ? status_tag( "PREMIUM", :ok ) : ""
    end

    column "Publish At" do |activity|
      text = activity.publishing_schedule ? activity.publishing_schedule.publish_at.localtime.strftime('%a %b %d, %Y %l:%M %p %Z') : "Schedule..."
      link_to text,
      edit_admin_publishing_schedule_path(activity)
    end

    column :title, sortable: :title do |activity|
      link_to(activity.title.html_safe, activity_path(activity))
    end

    actions
  end

  form do |f|
    f.inputs "Activity" do
      f.input :title
    end
    f.inputs "Schedule", for: [:publishing_schedule, f.object.publishing_schedule] do |ps|
      ps.input :publish_at, as: :just_datetime_picker
    end
  end
end

