ActiveAdmin.register Activity do
  config.sort_order = 'activity_order_asc'

  menu priority: 2

  action_item only: [:index] do
    link_to('Order Activties', activities_order_admin_activities_path)
  end

  action_item only: [:show, :edit] do
    link_to_publishable activity, 'View on Site'
  end

  action_item only: [:show] do
    link_to('Order Recipe Steps', recipe_steps_order_admin_activity_path(activity))
  end

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  index do
    column 'Link' do |activity|
      link_to_publishable(activity)
    end
    column :title, sortable: :title do |activity|
      activity.title.html_safe
    end
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
    column :published
    default_actions
  end

  controller do
    def create
      equipment_attrs = separate_equipment
      recipe_attrs = separate_recipes
      step_attrs = separate_steps
      @activity = Activity.create(params[:activity])
      @activity.update_equipment(equipment_attrs)
      @activity.update_recipes(recipe_attrs)
      @activity.update_steps(step_attrs)
      create!
    end

    def update
      @activity = Activity.find(params[:id])
      @activity.update_equipment(separate_equipment)
      @activity.update_recipes(separate_recipes)
      @activity.update_steps(separate_steps)
      update!
    end

    private

    def separate_equipment
      params[:activity].delete(:equipment)
    end

    def separate_recipes
      params[:activity].delete(:recipes)
    end

    def separate_steps
      params[:activity].delete(:steps)
    end
  end

  collection_action :activities_order, method: :get do
    @activities = Activity.ordered.all
  end

  collection_action :update_activities_order, method: :post do
    params[:activity_ids].each do |activity_id|
      activity = Activity.find(activity_id)
      if activity
        activity.activity_order_position = :last
        activity.save!
      end
    end

    redirect_to({action: :index}, notice: "Activity order has been updated")
  end

  member_action :recipe_steps_order, method: :get do
    @activity = Activity.find(params[:id])
  end

  member_action :update_recipe_steps_order, method: :put do
    recipe_step_ids = params[:activity][:recipe_steps][:ids]
    activity = Activity.find(params[:id])
    activity.update_recipe_step_order(recipe_step_ids)

    redirect_to({action: :show}, notice: "Recipe Steps Order has been updated")
  end
end

