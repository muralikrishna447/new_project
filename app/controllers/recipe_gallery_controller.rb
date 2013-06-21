class RecipeGalleryController < ApplicationController

  has_scope :by_published_at
  has_scope :difficulty
  has_scope :published_status

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes_count = Activity.published.recipes.count
  end

  def index_as_json
    if ["Unpublished", "All"].find(params[:published_status]) then
      @recipes = apply_scopes(Activity).recipes.page(params[:page]).per(12)
    else
      @recipes = apply_scopes(Activity).recipes.includes(:steps).page(params[:page]).per(12)
    end

    respond_to do |format|
      format.json { render :json => @recipes.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end
end