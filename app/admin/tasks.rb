require './lib/copy_creator'

ActiveAdmin.register_page "Tasks" do

  menu false
  content title: 'Super Admin Tasks' do
    h2 "The following tasks should only be run by developers of ChefSteps.com", style: 'color: red'
    render 'task_list'
  end

  page_action :create_display_quantities, method: :post do
    # self in this context is the controller
    class << self
      include ActionView::Helpers::NumberHelper
    end

    (RecipeIngredient.all + StepIngredient.all).each do |ingredient|
      ingredient.display_quantity = number_with_precision(ingredient.quantity, precision: 2, strip_insignificant_zeros: true)
      ingredient.save!
    end
    redirect_to({action: :index}, notice: "Quantities updated successfully!")
  end

  page_action :update_activity_recipe_steps, method: :post do
    Activity.all.map(&:update_recipe_steps)
    redirect_to({action: :index}, notice: "Activity recipe steps updated successfully!")
  end

  page_action :create_new_copy, method: :post do
    CopyCreator.create
    redirect_to({action: :index}, notice: "Copy created successfully!")
  end

  page_action :publish_all_activities, method: :post do
    Activity.all.each do |activity|
      activity.published = true
      activity.save!
    end

    redirect_to({action: :index}, notice: "Activities published!")
  end
end
