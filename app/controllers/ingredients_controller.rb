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
        begin
          if @ingredient.sub_activity_id && params[:ingredient][:title] != @ingredient.title
            raise "Can't change name of ingredient that is a recipe"
          else
            @ingredient.update_attributes(params[:ingredient])
            head :no_content
          end
        rescue Exception => e
          messages = [] || @ingredient.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def destroy
    authorize! :update, Ingredient
    @ingredient = Ingredient.find(params[:id])
    respond_to do |format|
      format.json do
        begin
          if @ingredient.sub_activity_id
            raise "Can't delete ingredient that is a recipe"
          elsif (@ingredient.activities.count) > 0 || (@ingredient.steps.count > 0)
            raise "Can't delete an ingredient that is in use"
          else
            @ingredient.destroy
            head :no_content
          end
        rescue Exception => e
          messages = [] || @ingredient.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

end
