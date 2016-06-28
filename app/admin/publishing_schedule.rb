
ActiveAdmin.register Activity, as: 'Content Calendar' do
  config.filters = false
  #config.sort_order = 'publishing_schedule_desc'

  menu priority: 2

  def scoped_collection
    super.includes :publishing_schedule
  end

  index do
    column 'Link' do |activity|
      link_to_publishable(activity)
    end
    column :premium
    column :title, sortable: :title do |activity|
      activity.title.html_safe
    end
    column "Publish At" do |activity|
      activity.publishing_schedule ? activity.publishing_schedule.publish_at : "Set"
    end
  end

  controller do
  end

end

