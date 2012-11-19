ActiveAdmin.register Quiz do
  menu parent: 'More'

  index do
    column :id
    column :title
    column :activity
    default_actions
  end
end

