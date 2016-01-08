module Api
  module V0
    class ActivitiesController < BaseController

      instrument_action :index, :show

      has_scope :sort, default: 'newest' do |controller, scope, value|
        case value
          when "oldest"
            scope.by_published_at("asc")
          when "newest"
            scope.by_published_at("desc")
          when "popular"
            scope.popular
          when "relevance"
            # Relevance is the default sort for pg_search so don't need to do anything
            scope
          else
            scope.by_published_at("desc")
        end
      end

      # Must be listed after :sort to combine correctly

      has_scope :difficulty
      has_scope :include_in_gallery
      has_scope :published
      has_scope :search_all

      has_scope :generator, default: "chefsteps" do |controller, scope, value|
        value == "chefsteps" ? scope.chefsteps_generated : scope.any_user_generated
      end

      has_scope :published_status, default: "published" do |controller, scope, value|
        value == "published" ? scope.published.include_in_gallery : scope.by_created_at('desc').unpublished.where("title != ''")
      end

      def index
        per = params[:per] ? params[:per] : 12
        if params[:difficulty] == 'any'
          params.delete 'difficulty'
        end
        if params[:search_all] && ! params[:sort]
          params[:sort] = "relevance"
        end
        @activities = apply_scopes(Activity).uniq().page(params[:page]).per(per)
        render json: @activities, each_serializer: Api::ActivityIndexSerializer
      end

      def show
        begin
          @activity = Activity.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_api_response 404, {message:'Activity not found'}
          return
        end

        http_auth =  request.headers['HTTP_AUTHORIZATION']
        ensure_authorized(false) if http_auth.present?

        if @user_id_from_token
          @user = User.find @user_id_from_token
          if @user && @user.role == 'admin'
            render json: @activity, serializer: Api::ActivitySerializer
          else
            if @activity.show_only_in_course
              render json: @activity, serializer: Api::ActivityAssemblySerializer
            else
              render json: @activity, serializer: Api::ActivitySerializer
            end
          end
        else
          if @activity.published
            if is_google || is_static_render
              render json: @activity, serializer: Api::ActivitySerializer
            else
              if @activity.show_only_in_course
                render json: @activity, serializer: Api::ActivityAssemblySerializer
              else
                render json: @activity, serializer: Api::ActivitySerializer
              end
            end
          else
            render_unauthorized
          end
        end
      end

      def likes
        @activity = Activity.find(params[:id])
        render json: @activity.likes, each_serializer: Api::ActivityLikeSerializer
      end
    end
  end
end
