class IngredientsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.json do
        result = Ingredient.where('title iLIKE ?', '%' + params[:q] + '%').all
        #result = result.select { |i| (! i.sub_activity_id) || Activity.find(i.sub_activity_id).published || (Activity.find(i.sub_activity_id).creator == nil) }
        render :json => result.to_json(include: [activities: {only: :id}, steps: {only: :id}])
      end

      format.html do
        render
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        @ingredient = Ingredient.find(params[:id])
        @ingredient.update_attributes(params[:ingredient])
        head :no_content
      end
    end
  end
end
