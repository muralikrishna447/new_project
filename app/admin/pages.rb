ActiveAdmin.register Page do
  permit_params :title, :content, :image_id, :primary_path, :short_description, :published,
                :show_footer, :components_attributes, :is_promotion, :redirect_path, :discount_id

  form :partial => "form"

  filter :title
  filter :content
  filter :slug
  filter :created_at
  filter :updated_at
  filter :primary_path
  filter :short_description
  filter :show_footer
  filter :published
  filter :is_promotion
  filter :redirect_path

  index do
    selectable_column
    id_column
    column :title
    column :content
    column :slug
    column :created_at
    column :updated_at
    column :primary_path
    column :short_description
    column :show_footer
    column :published
    column :is_promotion
    column :redirect_path
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :content
      row :slug
      row :created_at
      row :updated_at
      row :likes_count
      row :primary_path
      row :short_description
      row :show_footer
      row :published
      row :is_promotion
      row :redirect_path
    end
  end


end