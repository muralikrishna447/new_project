ActiveAdmin.register Menu do
  menu parent: 'More'

  form :partial => "form"


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :url, :parent_id
  #
  # or
  #
  permit_params do
    permitted = [:name, :url, :parent_id, :is_studio, :is_premium, :is_free, :is_not_logged, :position]
    # permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end

  index do
    selectable_column
    column :id
    column :name
    column "URL" do |menu|
      truncate(menu.url, length: 50)
    end
    column "Parent Menu" do |menu|
      truncate(menu.parent_menu.try(:name))
    end
    column :is_studio
    column :is_premium
    column :is_free
    column :is_not_logged
    column :created_at
    column :updated_at
    actions
  end

  action_item :only => :index do
    link_to('Reorder Menus', reorder_menus_admin_menus_path)
  end

  collection_action :reorder_menus, :method => :get do
    @menus = Menu.all
  end

  collection_action :update_reorder_menus, :method => :post do
    params[:menu_ids].each_with_index do |id, index|
      menu = Menu.find(id)
      menu.update(position: index + 1)
    end
    redirect_to admin_menus_path
  end
  
end
