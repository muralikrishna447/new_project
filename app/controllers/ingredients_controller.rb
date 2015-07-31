class IngredientsController < ApplicationController
  respond_to :json

  has_scope :include_sub_activities, default: "false" do |controller, scope, value|
    value == "false" ? scope.no_sub_activities : scope
  end

  has_scope :search_title do |controller, scope, value|
    controller.params[:exact_match] == "true" ? scope.exact_search(value) : scope.search_title(value)
  end

  has_scope :image do |controller, scope, value|
    case value
    when "with_image"
      value = scope.with_image
    when "no_image"
      value = scope.no_image
    else
      value = scope
    end
  end

  has_scope :purchaseable do |controller, scope, value|
    value == "with_purchase_link" ? scope.with_purchase_link : scope.no_purchase_link
  end

  has_scope :edit_level do |controller, scope, value|
    case value
    when "not_started"
      value = scope.not_started
    when "started"
      value = scope.started
    when "well_edited"
      value = scope.well_edited
    else
      value = scope
    end
  end

  has_scope :sort do |controller, scope, value|
    case value
      when "name"
        scope.order('title ASC')
      when "recently_added"
        scope.order('created_at DESC')
      when "recently_edited"
        scope.order('updated_at DESC')
      when "most_edited"
        scope.select("DISTINCT count(DISTINCT(events.user_id)), ingredients.*").joins(:events).where(events: {action: 'edit'}).group('ingredients.id').order("count(DISTINCT(events.user_id)) DESC")
      when "most_used"
        scope.select("DISTINCT count(DISTINCT(activity_ingredients.id)), ingredients.*").joins(:activity_ingredients).group('ingredients.id').order("count(DISTINCT(activity_ingredients.id)) DESC")
      else
        # Relevance is the default sort for pg_search so don't need to do anything
        scope
    end
  end

  # Must be listed after :sort to combine correctly
  has_scope :search_all


  def index
    respond_to do |format|
      format.json do

        sort_string = (params[:sort] || "title") + " " + (params[:dir] || "ASC").upcase
        if params[:include_sub_activities] == "true"
          # I couldn't get this to combine with the other scopes, but in the situation where we use this we don't actually need anything else so
          # going with naked SQL.
          result = Ingredient.find_by_sql(["SELECT * FROM ingredients i JOIN activities a ON i.sub_activity_id = a.id WHERE i.title iLIKE ? AND source_activity_id IS NULL AND a.title <> '' ORDER BY a.title ASC LIMIT ? OFFSET ?", "%#{params[:search_title]}%", params[:limit] || 20, params[:offset] || 0])
        else
          result = apply_scopes(Ingredient).where("title <>''").order(sort_string).offset(params[:offset]).limit(params[:limit])
        end

        if params[:detailed] == "true"
          result = result.includes(:activities, steps: [:activity])
          render :json => result.as_json(include: {activities: {only: [:id, :title]}, steps: {only: :id, include: {activity: {only: [:id, :title]}}}})
        else
          render :json => result.to_json
        end
      end
    end
  end

  # Ugh, this should be temporary and moved into API, it just is getting too mess to share with the default index used for the manager
  def index_for_gallery
    respond_to do |format|
      format.json do
        result = apply_scopes(Ingredient).where("title <>''").page(params[:page]).per(12)
        render :json => result.to_json()
      end
    end
  end

  def manager
    respond_to do |format|
      format.html do
        authorize! :manage, Ingredient unless Rails.env.angular?
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
            @ingredient.store_revision do
              @ingredient.update_attributes(params[:ingredient])

              # Why on earth are tags and steps not root wrapped but equipment and ingredients are?
              # I'm not sure where this happens, but maybe using the angular restful resources plugin would help.
              tags = params.delete(:tags)
              @ingredient.tag_list = tags.map { |t| t[:name]} if tags
              @ingredient.save!
              track_event(@ingredient, 'edit')
            end

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

  def create
    authorize! :create, Ingredient
    respond_to do |format|
      format.json do
        begin
          @ingredient = Ingredient.new(params[:ingredient])
          @ingredient.save!
          render :json => @ingredient, root: false
        rescue Exception => e
          messages = []
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def destroy
    authorize! :manage, Ingredient
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
          puts $@
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def show
    @ingredient_id = params[:id]
    @ingredient = Ingredient.find(params[:id])
  end

  def get_as_json
    @ingredient = Ingredient.find(params[:id])
    render json: @ingredient
  end

  def merge
    authorize! :manage, Ingredient
    puts "Merging " + @ingredients.inspect
    puts "Into " + @result_ingredient.inspect
    respond_to do |format|
      format.json do
        begin
          @result_ingredient = Ingredient.find(params[:id])
          @ingredients = Ingredient.find(params[:merge].split(','))
          @result_ingredient.merge(@ingredients)
          head :no_content
        rescue Exception => e
          messages = [] || @ingredient.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

    # TODO: duplicate code in activities_controller.rb
  def get_all_tags
    result = ActsAsTaggableOn::Tag.where('name iLIKE ?', '%' + (params[:q] || '') + '%').all
    respond_to do |format|
      format.json {
        render :json => result.to_json()
      }
    end
  end
end
