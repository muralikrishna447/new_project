class HomeController < ApplicationController
  # expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
  # expose(:bio_chris) { Copy.find_by_location('creator-chris') }
  # expose(:bio_grant) { Copy.find_by_location('creator-grant') }
  # expose(:bio_ryan) { Copy.find_by_location('creator-ryan') }
  # expose(:version) { Version.current }

  def index
    # @featured_id = Video.featured_id
    # @filmstrip = Video.filmstrip_videos
    # @croppable = @filmstrip.map(&:class).include?(Activity)
    @recipes = Activity.published.joins(:recipes).last(6)
  end

  def about
  	
  end
end
