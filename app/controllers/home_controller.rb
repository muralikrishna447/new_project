class HomeController < ApplicationController
  expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
  expose(:bio_chris) { Copy.find_by_location('creator-chris') }
  expose(:bio_grant) { Copy.find_by_location('creator-grant') }
  expose(:bio_ryan) { Copy.find_by_location('creator-ryan') }

  def index
    @featured_video = Video.featured_random
    @filmstrip = []
    @filmstrip << @featured_video
    Video.filmstrip.limit(4).each do |video|
      @filmstrip << video
    end
  end
end
