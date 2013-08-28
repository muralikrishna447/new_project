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
        #result = Ingredient.where('title iLIKE ?', '%' + params[:q] + '%').order(:title).offset(params[:offset]).limit(params[:limit])
        #result = result.select { |i| (! i.sub_activity_id) || Activity.find(i.sub_activity_id).published || (Activity.find(i.sub_activity_id).creator == nil) }
        render :json => result.as_json(include: {activities: {only: :id}, steps: {only: :id, include: {activity: {only: :id}}}})
        #render :json => result.to_json
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
