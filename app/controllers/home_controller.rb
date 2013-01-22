class HomeController < ApplicationController
  expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
  expose(:bio_chris) { Copy.find_by_location('creator-chris') }
  expose(:bio_grant) { Copy.find_by_location('creator-grant') }
  expose(:bio_ryan) { Copy.find_by_location('creator-ryan') }

  def index
    @filmstrip = Video.filmstrip_videos
    @new_content = Activity.published.with_video.order('updated_at DESC').limit(5)
  end
end
