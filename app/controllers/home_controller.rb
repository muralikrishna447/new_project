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
    @recipes = Activity.published.recipes.includes(:steps).order("RANDOM()").first(6)
    @techniques = Activity.published.techniques.includes(:steps).order("RANDOM()").first(6)
    @sciences = Activity.published.sciences.includes(:steps).order("RANDOM()").first(6)
    @heroes = [ Activity.published.recipes.includes(:steps).order('updated_at ASC').last,
                Activity.published.techniques.includes(:steps).last,
                Activity.published.sciences.includes(:steps).last ]
    @discussion = Forum.discussions.first
    @status = Twitter.status_embed
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
  end
end
