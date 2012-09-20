module ApplicationHelper
  def s3_image_url(image_id)
    "https://delve-staging.s3.amazonaws.com/#{image_id}"
  end

  def quantity_number(quantity)
    number_with_precision(quantity, precision: 2, strip_insignificant_zeros: true)
  end
end

