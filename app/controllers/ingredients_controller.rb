class IngredientsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.json do
        result = Ingredient.where('title iLIKE ?', '%' + params[:q] + '%').all
        #result = result.select { |i| (! i.sub_activity_id) || Activity.find(i.sub_activity_id).published || (Activity.find(i.sub_activity_id).creator == nil) }
        respond_with result
      end

      format.html do
        render
      end
    end
  end

end
