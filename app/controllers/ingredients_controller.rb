class IngredientsController < ApplicationController
  respond_to :json

  def index
    result = Ingredient.where('title iLIKE ?', '%' + params[:q] + '%').all
    result = result.select { |i| (! i.sub_activity_id) || Activity.find(i.sub_activity_id).published }
    respond_with result
  end

end
