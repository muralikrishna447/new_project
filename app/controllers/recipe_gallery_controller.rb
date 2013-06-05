class RecipeGalleryController < ApplicationController

  has_scope :difficulty

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
  end
end