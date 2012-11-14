class HomeController < ApplicationController
  include ActionCaching
  caches_actions

  expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
  expose(:bio_chris) { Copy.find_by_location('creator-chris') }
  expose(:bio_grant) { Copy.find_by_location('creator-grant') }
  expose(:bio_ryan) { Copy.find_by_location('creator-ryan') }
end
