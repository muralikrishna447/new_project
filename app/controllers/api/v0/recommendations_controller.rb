module Api
  module V0
    class RecommendationsController < BaseController
      before_filter :ensure_authorized_or_anonymous

      # Recommend one or more pieces of content, potentially including ads, that should be
      # shown to a user. The inputs are:
      #
      # platform (required) - e.g. 'jouleApp', 'website'
      # page (required) - a relative URL on the platform, e.g. '/', '/activities/pork-belly'
      # slot - if a target page has more than one place to insert recommendations, a named slot like "footer"
      # aspect - if a target can only accept certain aspects, a named aspect such as "16:9". It is preferable
      #          to be fully responsive and handle any shape gracefully.
      # limit - maximum number of desired results
      # user - this comes from the normal auth headers; anonymous is always allowed
      #
      # Other parameters may be passed in and they will be gathered as a generic hash of metadata
      # and passed to the recsys, which may or may not use them.
      #
      # Output is an array of recommendation items as JSON with the following fields, all of which
      # may be blank.
      #
      # image - absolute URL of image; if on http://d92f495ogyf88.cloudfront.net maybe assumed to
      # accept filepicker style /convert modifiers.
      # title - headline text
      # description - body text
      # buttonTitle - suggested text for any button, if the whole recommendation isn't clickable.
      # url - target where user should be taken if recommendation clicked
      # campaign - the utm_campaign that should be added to the target. utm_source and utm_medium
      #            should also be added by the client

      def index
        platform = params.delete(:platform)

        # Legacy recsys for activities only if platform isn't specified
        if platform.blank?
          tags = params.delete(:tags)
          @results = Activity.chefsteps_generated.include_in_gallery.published.tagged_with(tags, any: true).order('published_at desc').page(params[:page]).per(8)
          render json: @results, each_serializer: Api::ActivityIndexSerializer

        # Super-fancy modern recsys - not so much
        else
          metadata = params.dup
          page = metadata.delete(:page)
          slot = metadata.delete(:slot)
          aspect = metadata.delete(:aspect)
          limit = metadata.delete(:limit).to_i || 1
          connected = (metadata.delete(:connected) == 'true')

          circulator_owner = @user_id_from_token && (current_api_user.owned_circulators.count > 0 || current_api_user.joule_purchase_count > 0)

          ads = []

          # These are the only two known uses right now. Anything else, we got no recommendations.
          # Which isn't considered an error.
          if platform == 'jouleApp' && slot == 'homeHero'
            if circulator_owner || connected
              ads = Advertisement.where(matchname: 'homeHeroOwner').published.all.to_a

              # TODO: remove this hack for bacon ad. We hadn't thought through the problem that an ad
              # could be for a URL to content the app doesn't have yet. In the future, the app should
              # filter those out or retrieve them in real time.
              unless version_gte(request.headers['X-Application-Version'], '2.42')
                ads.delete_if { |ad| ad[:campaign] == 'baconGuideAd' }
              end

              ads = ads.sample(limit).to_a
            else
              ads = Advertisement.where(matchname: 'homeHeroNonOwner').published.all.sample(limit).to_a
            end
          end

          render_api_response 200, ads, Api::AdvertisementSerializer
        end
      end

      def version_gte(version, min_version)
        return false if version.blank?
        # Thanks, Gem module!!
        Gem::Version.new(version) >=  Gem::Version.new(min_version)
      end
    end
  end
end
