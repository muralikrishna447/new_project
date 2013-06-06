class SciencesController < ApplicationController
  def index
    @sciences = Activity.sciences.published.page(params[:page]).per(12)
  end

  def index_as_json
    @techniques = Activity.sciences.published.order('created_at DESC')
    respond_to do |format|
      format.json { render :json => @techniques.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :updated_at, :slug], :include => :steps) }
    end
  end

  def show
    @science = Activity.sciences.find(params[:id])
  end
end