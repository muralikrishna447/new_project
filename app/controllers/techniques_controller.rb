class TechniquesController < ApplicationController

  has_scope :by_published_at
  has_scope :by_updated_at
  has_scope :difficulty
  has_scope :published_status, default: "Published" do |controller, scope, value|
    value == "Published" ? scope.published.techniques.includes(:steps) : scope.unpublished.techniques.where("title != 'DUMMY NEW ACTIVITY'")
  end

  def index
    @techniques = apply_scopes(Activity).techniques.order('published_at DESC').uniq.page(params[:page]).per(12)
    @techniques_count = Activity.published.techniques.count
  end

  def index_as_json
    @techniques = apply_scopes(Activity).page(params[:page]).per(12)

    respond_to do |format|
      format.json { render :json => @techniques.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end
  
  def show
    @technique = Activity.techniques.find(params[:id])
  end
end