ActiveAdmin.register Activity do

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  index do
    column "Order", :activity_order
    column :title
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
    default_actions
  end
end

