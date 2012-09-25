class HomeController < ApplicationController
  include AggressiveCaching
  expose(:homepage_blurb) { Copy.find_by_location('homepage-blurb') }
end
