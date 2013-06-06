class RecipeGalleryController < ApplicationController

  has_scope :by_order
  has_scope :difficulty

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
  end

  def index_as_json
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC')
    respond_to do |format|
      format.json { render :json => @recipes.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :updated_at, :slug], :include => :steps) }
    end
  end
end