ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'

  controller do
    def create
      ingredients = seperate_ingredients
      @recipe = Recipe.create(params[:recipe]).update_ingredients(ingredients)
      create!
    end

    def update
      ingredients = seperate_ingredients
      @recipe = Recipe.find(params[:id]).update_ingredients(ingredients)
      update!
    end

    private
    def seperate_ingredients
      params[:recipe].delete(:ingredients)
    end
  end
end

