class IngredientsController < ApplicationController
  respond_to :json

  def index
    result = Ingredient.where('title iLIKE ?', '%' + params[:q] + '%').all
    respond_with result
  end

end
