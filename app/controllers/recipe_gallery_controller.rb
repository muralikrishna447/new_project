class RecipeGalleryController < ApplicationController

  has_scope :by_published_at
  has_scope :difficulty

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes_count = Activity.published.recipes.count
  end

  def index_as_json
    @recipes = apply_scopes(Activity).published.recipes.order('published_at DESC').includes(:steps).page(params[:page]).per(12)
    respond_to do |format|
      format.json { render :json => @recipes.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end
end