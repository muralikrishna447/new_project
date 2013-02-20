class RecipeGalleryController < ApplicationController

  def index
      @results = Kaminari.paginate_array(Activity.where(published: true).order("created_at DESC").select{|a| a.is_recipe?}).page(params[:page]).per(15)
  end
end