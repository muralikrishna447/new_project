require './lib/copy_creator'

ActiveAdmin.register_page "Tasks" do

  menu false
  content title: 'Super Admin Tasks' do
    h2 "The following tasks should only be run by developers of ChefSteps.com", style: 'color: red'
    render 'task_list'
  end

  page_action :create_new_copy, method: :post do
    CopyCreator.create
    redirect_to({action: :index}, notice: "Copy created successfully!")
  end

  page_action :publish_all_activities, method: :post do
    Activity.all.each do |activity|
      activity.published = true
      activity.save!
    end

    redirect_to({action: :index}, notice: "Activities published!")
  end

  page_action :create_activity_slugs, method: :post do
    Activity.all.map(&:save!)
    redirect_to({action: :index}, notice: "Activity slugs created successfully!")
  end


end
