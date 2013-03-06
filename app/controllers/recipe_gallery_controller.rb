class RecipeGalleryController < ApplicationController

  def index
      @recipes = Activity.published.recipes.order('created_at DESC').uniq.page(params[:page]).per(12)
  end
end