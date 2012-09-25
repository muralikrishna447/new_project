module ApplicationHelper
  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def quantity_number(quantity)
    number_with_precision(quantity, precision: 2, strip_insignificant_zeros: true)
  end
end

