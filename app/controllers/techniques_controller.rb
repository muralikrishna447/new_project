class TechniquesController < ApplicationController
  def index
    @techniques = Activity.techniques.published.page(params[:page]).per(12)
  end

  def index_as_json
    @techniques = Activity.techniques.published.randomize
    respond_to do |format|
      format.json { render :json => @techniques.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :updated_at, :slug], :include => :steps) }
    end
  end

  def show
    @technique = Activity.techniques.find(params[:id])
  end
end