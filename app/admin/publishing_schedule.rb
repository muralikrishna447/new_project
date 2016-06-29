
ActiveAdmin.register Activity, as: 'Content Calendar' do
  config.filters = false
  config.sort_order = ''
  config.paginate = false

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

  index do
    column :title, sortable: :title do |activity|
      link_to(activity.title.html_safe, activity_path(activity))
    end
    column :premium
    column "Publish At", sortable: 'publishing_schedule.publish_at' do |activity|
      activity.publishing_schedule ? activity.publishing_schedule.publish_at : "Set"
    end
  end
end

