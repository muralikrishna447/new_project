ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'

  controller do
    def create
      ingredient_attrs =  separate_ingredients
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
end

