module ApplicationHelper
  def s3_image_url(image_id)
    case Rails.env
    when 'development'
      root = "https://chefsteps-staging.s3.amazonaws.com"
    when 'staging'
      root = "https://chefsteps-staging.s3.amazonaws.com"
    when 'production'
      root = "https://chefsteps-production.s3.amazonaws.com"
    end
    [root, image_id].compact.join('/')
  end

  def quantity_number(quantity)
    number_with_precision(quantity, precision: 2, strip_insignificant_zeros: true)
  end
end

