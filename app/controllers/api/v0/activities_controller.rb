module Api
  module V0
    class ActivitiesController < BaseController

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
        t1 = Time.now
        begin
          @activity = Activity.find(params[:id])
          @version = params[:version]
          @last_revision = @activity.last_revision()
          cache_revision = @last_revision ? @last_revision.revision : '0'
          if @version && @version.to_i <= @last_revision.revision
            @activity = @activity.restore_revision(@version)
            cache_revision = @version
          end
        rescue ActiveRecord::RecordNotFound
          render_api_response 404, {message:'Activity not found'}
          return
        end

        http_auth =  request.headers['HTTP_AUTHORIZATION']
        ensure_authorized(false) if http_auth.present?

        @user = nil
        if @user_id_from_token
          @user = User.find @user_id_from_token
        end
        user_premium = @user && @user.premium?

        can_see = false
        trimmed = false

        if @activity.published
          # Everyone can see any published recipe, but if it is a premium recipe and not
          # a premium user, they get the trimmed version.
          # We also allow prerender.io to see everything in order to implement
          # First Click Free (https://support.google.com/news/publisher/answer/40543?topic=11707)
          can_see = true
          trimmed = @activity.premium && (! user_premium) && (! is_static_render)

          # Grandfather clause. User enrolled in Shrimp Brains class when it was
          # free, never bought a class so they aren't premium, but now we decided to make Shrimp Brains premium.
          # They should still have access.
          #
          # This is potentially a bit slow to check b/c it involved a recursive walk of
          # the assembly tree so only check it if necessary
          if trimmed && @user
            assembly = @activity.containing_course
            if assembly && @user.class_enrollment(assembly)
              trimmed = false
            end
          end
        else
          # Unpublished stuff can only be seen by privileged users or the activity's creator, as specified in ability.rb
          can_see = can?(:manage, @activity)
        end

        if can_see
          except = trimmed ? [:steps, :ingredients, :equipment] : []
          cache_key = "activity-#{@activity.id}-v#{cache_revision}-t#{trimmed}"
          logger.info "fetching activity from #{cache_key}"
          metric_suffix = 'hit'
          serialized = Rails.cache.fetch(cache_key, expires_in: 60.minutes) do
            logger.info "cache miss for #{cache_key}"
            metric_suffix = 'miss'
            Api::ActivitySerializer.new(@activity, except: except) \
              .serializable_object.to_json
          end

          # Because we are fetching objects through the cache, the
          # return type will always be a string.  Need to manually set
          # content-type
          render text: serialized, content_type: 'application/json'

          # TODO: look into breaking this into separate methods and
          # using a filter, or hooking into ActiveSupport for timing
          # metrics
          delta = Time.now - t1
          metric_name = "activity.show.time.#{metric_suffix}"
          logger.info "#{metric_name} took #{delta}s"
          Librato.timing metric_name, delta * 1000
          Librato.increment "activity.show.count.#{metric_suffix}"
        else
          render_unauthorized
        end

        # TODO logging
      end

      def likes
        @activity = Activity.eager_load(:likes).find(params[:id])
        render json: @activity.likes, each_serializer: Api::ActivityLikeSerializer
      end
    end
  end
end
