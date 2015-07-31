class GalleryController < ApplicationController
  after_filter :track_iphone_app_activity, only: :index_as_json

  # This is legacy only for the cs-mobile app until we change it to call Algolia directly
  # There are no other clients.
  # We'd have to do this anyhow b/c even if we push an app update, you'll have old versions
  # out there that depend on this API for a long time.
  # This is a lot of duplication of what is in api.js.coffee, not delightful.
  def index_as_json

    # Difficulty is handled as a facet instead of a filter, because there aren't string filters
    facetFilters = []
    if params['difficulty'] && params['difficulty'].downcase != 'any'
      facetFilters.push("difficulty:#{params['difficulty'].downcase}")
    end

    # Translate these boolean filters to numeric. Only allowing published since
    # app isn't allowed unpubbed access anyhow.
    chefsteps_generated = (params['generator'] || '').downcase == 'chefsteps' ? 1 : 0
    numericFilters = [
      "chefsteps_generated=#{chefsteps_generated}",
      "published=1",
      "include_in_gallery=1",
    ]

    slave = params[:sort] == 'newest' ? 'ChefStepsNewest' : 'ChefSteps'

    options = {
      hitsPerPage: 12,
      page: params['page'].to_i - 1,
      numericFilters: numericFilters,
      facetFilters: facetFilters,
      facets: '*',
      advancedSyntax: true,
      attributesToRetrieve: "title,url,image,likes_count",
      attributesToHighlight: "",
      attributesToSnippet: "",
      slave: slave
    }

    response = Activity.raw_search(params[:search_all] || '', options) rescue { hits: [] }

    # Translate Algolia JSON to match the old response from this API
    result = response['hits']
    if result
      result.each do |a|
        # Yes, that is encoded nested JSON - filepicker response. Avert your eyes.
        a['featured_image_id'] = "{\"url\": \"#{a['image']}\"}"
        a['show_only_in_course'] = 'false'
        a['id'] = a['objectID']
      end
    end

    respond_to do |format|
      format.json {
        render json: result.to_json
      }
    end
  end


  private
  def track_iphone_app_activity
    if from_ios_app?
      mixpanel.track(mixpanel_anonymous_id, '[iOS App] Gallery Page', {generator: params[:generator], page: params[:page], sort: params[:sort], activity_type: params[:activity_type], search: params[:search_all], context: "iOS App"})
    end
  end
end