ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'

  controller do
    def create
      ingredients = seperate_ingredients
      steps = seperate_steps
      @recipe = Recipe.create(params[:recipe])
      @recipe.update_ingredients(ingredients)
      @recipe.update_steps(steps)
      create!
    end

    def update
      ingredients = seperate_ingredients
      steps = seperate_steps
      @recipe = Recipe.find(params[:id])
      @recipe.update_ingredients(ingredients)
      @recipe.update_steps(steps)
      update!
    end

    private
    def seperate_ingredients
      params[:recipe].delete(:ingredients)
    end

    def seperate_steps
      params[:recipe].delete(:steps)
    end
  end
end

