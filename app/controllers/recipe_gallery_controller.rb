class RecipeGalleryController < ApplicationController

  def index
      @recipes = Activity.published.joins(:ingredients).order('created_at DESC').uniq.page(params[:page]).per(1)
  end
end