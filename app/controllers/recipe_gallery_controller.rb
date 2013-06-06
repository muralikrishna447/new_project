class RecipeGalleryController < ApplicationController

  has_scope :by_order
  has_scope :difficulty

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    # @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC')
    respond_to do |format|
      format.html { render :html => @recipes }
      format.json { render :json => @recipes.to_json }
    end
  end
end