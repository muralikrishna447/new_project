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
    @recipes = Activity.published.with_video.joins(:ingredients).order("RANDOM()").first(6)
    @discussions = Forum.discussions.take(3)
    @challenges = Forum.discussions_by_category('culinary-challenge')
    # @status = Twitter.status
  end

  def about
  	
  end
end
