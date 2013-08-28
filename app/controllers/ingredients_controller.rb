class IngredientsController < ApplicationController
  respond_to :json

  has_scope :include_sub_activities, default: "false" do |controller, scope, value|
    value == "false" ? scope.no_sub_activities : scope
  end
  has_scope :search_title

  def index
    respond_to do |format|
      format.json do
        sort_string = (params[:sort] || "title") + " " + (params[:dir] || "ASC").upcase
        result = apply_scopes(Ingredient).where("title <>''").order(sort_string).offset(params[:offset]).limit(params[:limit])
        if params[:detailed]
          render :json => result.as_json(include: {activities: {only: :id}, steps: {only: :id, include: {activity: {only: :id}}}})
        else
          render :json => result.to_json
        end
      end

      format.html do
        authorize! :update, Ingredient
        render
      end
    end
  end

  def update
    authorize! :update, Ingredient
    respond_to do |format|
      format.json do
        @ingredient = Ingredient.find(params[:id])
        if @ingredient.sub_activity_id && params[:ingredient][:title] != @ingredient.title
          render json: { errors: "Can't change name of ingredient that is a recipe"}, status: 422
        else
          @ingredient.update_attributes(params[:ingredient])
          head :no_content
        end
      end
    end
  end
end
