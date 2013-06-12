class TechniquesController < ApplicationController

  has_scope :by_published_at
  has_scope :difficulty

  def index
    @techniques = apply_scopes(Activity).techniques.published.page(params[:page]).per(12)
    @techniques_count = Activity.published.techniques.count
  end

  def index_as_json
    @techniques = apply_scopes(Activity).techniques.published.order('published_at DESC').includes(:steps).page(params[:page]).per(12)
    respond_to do |format|
      format.json { render :json => @techniques.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end

  def show
    @technique = Activity.techniques.find(params[:id])
  end
end