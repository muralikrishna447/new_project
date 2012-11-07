class ThankYouController < ApplicationController
  include AggressiveCaching
  before_filter :authenticate_user!, only: :show

  expose(:thank_you_intro) { Copy.find_by_location('thank-you-intro') }

  expose(:thank_you_image_left) { Copy.find_by_location('thank-you-image-left') }
  expose(:thank_you_image_left_caption) { Copy.find_by_location('thank-you-image-left-caption') }

  expose(:thank_you_image_middle) { Copy.find_by_location('thank-you-image-middle') }
  expose(:thank_you_image_middle_caption) { Copy.find_by_location('thank-you-image-middle-caption') }

  expose(:thank_you_image_right) { Copy.find_by_location('thank-you-image-right') }
  expose(:thank_you_image_right_caption) { Copy.find_by_location('thank-you-image-right-caption') }

end

