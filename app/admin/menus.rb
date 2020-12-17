ActiveAdmin.register Menu do
  menu parent: 'More'
  before_action :fetch_menu, only: [:update]
  form :partial => "form"

  permit_params :name, :url, :parent_id, :is_studio, :is_premium, :is_free, :is_not_logged

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

  controller do
    def update
      Menu.transaction do
        if @menu.is_parent_menu? && params[:menu][:parent_id].present?
          parent_sub_menu = Menu.find(params[:menu][:parent_id]).sub_menus.by_position.last
          sub_menu_position = parent_sub_menu.present? ? parent_sub_menu.position : 0
          sub_menu_position += 1
          @menu.position = sub_menu_position
          @menu.sub_menus.by_position.each do |sub_menu|
            sub_menu_position += 1
            sub_menu.parent_id = params[:menu][:parent_id]
            sub_menu.position = sub_menu_position
            sub_menu.save
          end
        elsif !@menu.is_parent_menu? && params[:menu][:parent_id].blank?
          main_menu_position = Menu.main_menus.last.position.to_i + 1
          @menu.position = main_menu_position
        end
        update!
      end
    end


    private

    def fetch_menu
      @menu = Menu.find(params[:id])
    end
  end

  collection_action :update_reorder_menus, :method => :post do
    params[:menu_ids].each_with_index do |id, index|
      menu = Menu.find(id)
      menu.update(position: index + 1)
    end
    redirect_to admin_menus_path
  end
  
end
