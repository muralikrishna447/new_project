ActiveAdmin.register Activity do
  config.sort_order = 'activity_order_asc'

  menu priority: 2

  action_item only: [:show, :edit] do
    link_to_publishable activity, 'View on Site'
  end

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  action_item only: [:show, :edit] do
    link_to('Edit Step Ingredients', associated_ingredients_admin_activity_path(activity))
  end


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
      step_attrs = separate_steps
      @activity = Activity.create(params[:activity])
      @activity.update_equipment(equipment_attrs)
      @activity.update_steps(step_attrs)
      create!
    end

    def update
      @activity = Activity.find(params[:id])
      @activity.update_equipment(separate_equipment)
      @activity.update_steps(separate_steps)
      @activity.update_ingredients(separate_ingredients)
      update!
    end

    private

    def separate_equipment
      params[:activity].delete(:equipment)
    end

    def separate_steps
      params[:activity].delete(:steps)
    end

    def separate_ingredients
      params[:activity].delete(:ingredients)
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


  member_action :associated_ingredients, method: :get do
    @activity = Activity.find(params[:id])
  end

  member_action :update_associated_ingredients, method: :put do
    @activity = Activity.find(params[:id])
    @activity.update_attributes(steps_attributes:params[:activity][:steps_attributes])
    params[:step_ingredients].each do |id, ingredients|
      Step.find(id).update_ingredients(ingredients)
    end
    redirect_to({action: :show}, notice: "Step's ingredients updated")
  end
end

