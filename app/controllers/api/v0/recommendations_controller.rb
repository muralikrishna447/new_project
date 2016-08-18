module Api
  module V0
    class RecommendationsController < BaseController

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
      # and passed to the recsys, which may or may not use them. An example would be
      # 'joulePaired' indicating whether the Joule app is paired with a circulator.
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
        tags = params.delete(:tags)
        platform = params.delete(:platform)

        # Legacy recsys for activities only if platform isn't specified
        if platform.blank?
          @results = Activity.chefsteps_generated.include_in_gallery.published.tagged_with(tags, any: true).order('published_at desc').page(params[:page]).per(8)
          render json: @results, each_serializer: Api::ActivityIndexSerializer

        # Super-fancy modern recsys - not so much
        else
          ensure_authorized_or_anonymous()
          page = params.delete(:page)
          slot = params.delete(:slot)
          aspect = params.delete(:aspect)
          limit = params.delete(:limit) || 1
          metadata = params

          ads = Advertisement.limit(limit)

          Rails.logger.info "Recommendation request #{params.inspect}, returning #{ads.count} results"

          render json: ads, each_serializer: Api::AdvertisementSerializer
        end
      end
    end
  end
end