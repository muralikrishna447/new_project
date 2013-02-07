class RecipeGalleryController < ApplicationController

  def index
      @results = Kaminari.paginate_array(Activity.where(published: true).order("created_at DESC").select{|a| a.has_recipes?}).page(params[:page]).per(15)
  end
end