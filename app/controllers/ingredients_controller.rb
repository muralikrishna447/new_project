class IngredientsController < ApplicationController
  respond_to :json

  has_scope :include_sub_activities, default: "false" do |controller, scope, value|
    value == "false" ? scope.no_sub_activities : scope
  end

  has_scope :search_title do |controller, scope, value|
    controller.params[:exact_match] == "true" ? scope.exact_search(value) : scope.search_title(value)
  end

  def index
    respond_to do |format|
      format.json do
        sort_string = (params[:sort] || "title") + " " + (params[:dir] || "ASC").upcase
        result = apply_scopes(Ingredient).where("title <>''").includes(:activities, steps: [:activity]).order(sort_string).offset(params[:offset]).limit(params[:limit])
        if params[:detailed]
          render :json => result.as_json(include: {activities: {only: [:id, :title]}, steps: {only: :id, include: {activity: {only: [:id, :title]}}}})
        else
          render :json => result.to_json
        end
      end

      format.html do
        authorize! :update, Ingredient unless Rails.env.angular?
        render
      end
    end
  end

  def update
    authorize! :update, Ingredient unless Rails.env.angular?
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
    authorize! :update, Ingredient unless Rails.env.angular?
    @ingredient = Ingredient.find(params[:id])
    respond_to do |format|
      format.json do
        begin
          if @ingredient.sub_activity_id
            raise "Can't delete ingredient that is a recipe"
          elsif (@ingredient.activities.count) > 0 || (@ingredient.steps.count > 0)
            raise "Can't delete an ingredient that is in use"
          else
            @ingredient.destroy unless Rails.env.angular?
            head :no_content
          end
        rescue Exception => e
          messages = [] || @ingredient.errors.full_messages
          messages.push(e.message)
          puts $@
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def show
  end

  def get_as_json
    @ingredient = Ingredient.find(params[:id])
    render json: @ingredient
  end


  def merge
    authorize! :update, Ingredient unless Rails.env.angular?
    puts "Merging " + @ingredients.inspect
    puts "Into " + @result_ingredient.inspect
    respond_to do |format|
      format.json do
        begin
          @result_ingredient = Ingredient.find(params[:id])
          @ingredients = Ingredient.find(params[:merge].split(','))
          @result_ingredient.merge(@ingredients) unless Rails.env.angular?
          head :no_content
        rescue Exception => e
          messages = [] || @ingredient.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

end
