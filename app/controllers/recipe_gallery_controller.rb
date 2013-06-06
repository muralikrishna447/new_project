class RecipeGalleryController < ApplicationController

  has_scope :most_recent, :type => :boolean
  has_scope :difficulty

  def index
    # @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
    @recipes = apply_scopes(Activity).published.recipes.uniq.page(params[:page]).per(12)
  end
end