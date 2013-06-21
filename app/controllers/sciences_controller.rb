class SciencesController < ApplicationController

  has_scope :by_published_at
  has_scope :by_updated_at
  has_scope :difficulty
  has_scope :published_status, default: "Published" do |controller, scope, value|
    value == "Published" ? scope.published.sciences.includes(:steps) : scope.unpublished.sciences.where("title != 'DUMMY NEW ACTIVITY'")
  end

  def index
    @sciences = apply_scopes(Activity).sciences.order('published_at DESC').uniq.page(params[:page]).per(12)
    @sciences_count = Activity.published.sciences.count
  end

  def index_as_json
    @sciences = apply_scopes(Activity).page(params[:page]).per(12)

    respond_to do |format|
      format.json { render :json => @sciences.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end
  
  def show
    @science = Activity.sciences.find(params[:id])
  end
end