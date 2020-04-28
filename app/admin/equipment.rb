ActiveAdmin.register Equipment do
  menu parent: 'More'
  permit_params :title, :product_url

  filter :title
  filter :product_url
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :title
    column :product_url
    actions
  end
end

