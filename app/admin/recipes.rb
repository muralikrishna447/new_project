ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'

  controller do
    def create
      ingredients = params[:recipe].delete(:ingredients)
      @recipe = Recipe.create(params[:recipe]).update_ingredients(ingredients)
      create!
    end
  end
end

