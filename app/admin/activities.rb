ActiveAdmin.register Activity do
  menu priority: 2
  action_item only: [:show, :edit] do
    link_to('View on Site', activity_path(activity))
  end

  action_item only: [:show] do
    link_to('Order Recipe Steps', recipe_steps_order_admin_activity_path(activity))
  end

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  index do
    column "Order", :activity_order
    column :title
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
    default_actions
  end

  controller do
    def create
      equipment_attrs = separate_equipment
      recipe_ids = separate_recipes
      @activity = Activity.create(params[:activity])
      @activity.update_equipment(equipment_attrs)
      @activity.update_recipes(recipe_ids)
      create!
    end

    def update
      @activity = Activity.find(params[:id])
      @activity.update_equipment(separate_equipment)
      @activity.update_recipes(separate_recipes)
      update!
    end

    private

    def separate_equipment
      params[:activity].delete(:equipment)
    end

    def separate_recipes
      params[:activity].delete(:recipes)
    end
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

