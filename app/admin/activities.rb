ActiveAdmin.register Activity do

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
end

