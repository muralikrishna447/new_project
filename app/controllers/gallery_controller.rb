class GalleryController < ApplicationController
  # TODO MIXPANEL
  # after_filter :track_iphone_app_activity, only: :index_as_json

  has_scope :sort do |controller, scope, value|
    case value
      when "oldest"
        controller.showing_published? ? scope.by_published_at("asc") : scope.by_updated_at("asc")
      when "newest"
        controller.showing_published? ? scope.by_published_at("desc") : scope.by_updated_at("desc")
      when "popular"
        scope.popular
      else
        # Relevance is the default sort for pg_search so don't need to do anything
        scope
    end
  end

  # Must be listed after :sort to combine correctly
  has_scope :search_all
  has_scope :difficulty
  has_scope :activity_type
  has_scope :include_in_gallery

  has_scope :generator, default: "chefsteps" do |controller, scope, value|
    value == "chefsteps" ? scope.chefsteps_generated : scope.any_user_generated
  end

  has_scope :published_status, default: "published" do |controller, scope, value|
    value == "published" ? scope.published.include_in_gallery : scope.unpublished.where("title != ''")
  end

  def index
    @show_app_add = true
    @recipes = []
   end

  def showing_published?
    @pub == "published"
  end

  def index_as_json
    @pub = params[:published_status] || "published"
    @recipes = apply_scopes(Activity).uniq().page(params[:page]).per(12)

    respond_to do |format|
      format.json { render :json => @recipes.to_json(only: [:id, :title, :description, :image_id, :featured_image_id, :difficulty, :published_at, :slug, :show_only_in_course, :likes_count], :include => [:steps, :creator], methods: [:gallery_path]) }
    end
  end


  private
  def track_iphone_app_activity
    if from_ios_app?
      mixpanel.track(mixpanel_anonymous_id, '[iOS App] Gallery Page', {generator: params[:generator], page: params[:page], sort: params[:sort], activity_type: params[:activity_type], search: params[:search_all], context: "iOS App"})
    end
  end
end