ActiveAdmin.register Ingredient do
  config.sort_order = "title_asc"

  index do
    column :id
    column "Source Activity", sortable: :sub_activity_id do |ingredient|
      if ingredient.sub_activity_id?
        link_to "Go", edit_admin_activity_path(ingredient.sub_activity_id)
      end
    end
    column :title
    column "Used In" do |ingredient|
      if ingredient.activities.size > 0
        link_to ingredient.activities.size, admin_ingredient_path(ingredient)
      end
    end
    column :for_sale
    column :product_url
    column :created_at
    column :updated_at
    default_actions
  end

  show do |ingredient|
    attributes_table do
      row :id
      row :title
      row :for_sale
      row :product_url
      row :created_at
      row :updated_at
      row "Source Activity" do
        if ingredient.sub_activity_id?
          link_to "Go", edit_admin_activity_path(ingredient.sub_activity_id)
        else
          "(None)"
        end
      end
      row "Used In" do
        ingredient.activities.each do |act|
          li link_to act.title.html_safe, edit_admin_activity_path(act)
        end
      end
    end
  end
end

