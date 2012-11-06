class HomeController < ApplicationController
  include AggressiveCaching
  expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
  expose(:bio_chris) { Copy.find_by_location('creator-chris') }
  expose(:bio_grant) { Copy.find_by_location('creator-grant') }
  expose(:bio_ryan) { Copy.find_by_location('creator-ryan') }
  expose(:carousel_images_copy) { Copy.find_by_location('carousel-images').copy }
  expose(:terms_of_service) { Copy.find_by_location('terms-of-service') }

end

