ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'

  action_item :only => [:show, :edit] do
    link_to('Edit step ingredients', associated_ingredients_admin_recipe_path(recipe))
  end

  controller do
    def create
      ingredient_attrs = separate_ingredients
      step_attrs = separate_steps
      @recipe = Recipe.create(params[:recipe])
      @recipe.update_ingredients(ingredient_attrs)
      @recipe.update_steps(step_attrs)
      create!
    end

    def update
      @recipe = Recipe.find(params[:id])
      @recipe.update_ingredients(separate_ingredients)
      @recipe.update_steps(separate_steps)
      update!
    end

    private

    def separate_ingredients
      params[:recipe].delete(:ingredients)
    end

    def separate_steps
      params[:recipe].delete(:steps)
    end
  end

  member_action :associated_ingredients, method: :get do
    @recipe = Recipe.find(params[:id])
  end

  member_action :update_associated_ingredients, method: :put do
    params[:step_ingredients].each do |id, ingredients|
      Step.find(id).update_ingredients(ingredients)
    end
    redirect_to({action: :show}, notice: "Step's ingredients updated")
  end
end

