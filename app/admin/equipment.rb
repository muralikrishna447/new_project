ActiveAdmin.register Equipment do
  menu parent: 'More'

  index do
    column :id
    column :title
    column :product_url
    default_actions
  end
end

