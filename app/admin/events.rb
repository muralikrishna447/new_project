ActiveAdmin.register Event do
  menu parent: 'Engagement'


  index do
    column :id
    column :action
    column :trackable_type
    column :created_at
    column :group_type
    column :group_name
    column "User" do |event|
      event.user.email
    end
    default_actions
  end

  csv do
    column :id
    column :action
    column :trackable_type
    column :created_at
    column :group_type
    column :group_name
    column :user_id
  end
end