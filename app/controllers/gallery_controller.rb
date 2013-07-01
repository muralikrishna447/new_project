class GalleryController < ApplicationController


  has_scope :sort do |controller, scope, value|
    pub = true
    case value
      when "oldest"
        pub ? scope.by_published_at("asc") : scope.by_updated_at("asc")
      when "newest"
        pub ? scope.by_published_at("desc") : scope.by_updated_at("desc")
      else
        # Relevance is the default sort for pg_search so don't need to do anything
        scope
    end
  end

  has_scope :search_all
  has_scope :difficulty
  has_scope :activity_type

  has_scope :published_status, default: "Published" do |controller, scope, value|
    value == "Published" ? scope.published : scope.unpublished.where("title != 'DUMMY NEW ACTIVITY'")
  end

  def index
    @recipes = []
    @recipes_count = Activity.published.recipes.count
  end

  def index_as_json
    @recipes = apply_scopes(Activity).page(params[:page]).per(12)

    respond_to do |format|
      format.json { render :json => @recipes.to_json(only: [:title, :image_id, :featured_image_id, :difficulty, :published_at, :slug], :include => :steps) }
    end
  end
end