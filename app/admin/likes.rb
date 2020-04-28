ActiveAdmin.register Like do
  menu parent: 'Engagement'
  permit_params :likeable_id, :likeable_type, :user_id
  config.clear_action_items!

  form :partial => "form"

  filter :likeable_type
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :user
    column :likeable
    column :likeable_type
    column :created_at
    column :updated_at
  end

end