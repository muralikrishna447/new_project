class SciencesController < ApplicationController
  def index
    @sciences = Activity.sciences.published.page(params[:page]).per(12)
    @sciences_count = Activity.published.sciences.count
  end

  def index_as_json
    @sciences = Activity.sciences.published.order('published_at DESC').includes(:steps).page(params[:page]).per(9)
    respond_to do |format|
      format.json { render :json => @sciences.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end

  def show
    @science = Activity.sciences.find(params[:id])
  end
end