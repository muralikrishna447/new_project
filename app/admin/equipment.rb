ActiveAdmin.register Equipment do

  index do
    column :id
    column :title
    column :product_url
    default_actions
  end
end

