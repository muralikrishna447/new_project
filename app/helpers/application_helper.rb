module ApplicationHelper
  def split_images_copy(copy)
    images = copy.split("\n")
    images.map! do |image|
      s3_image_url(image)
    end
  end

  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def quantity_number(quantity)
    number_with_precision(quantity, precision: 2, strip_insignificant_zeros: true)
  end

  def auth_trigger(target, form_number, &block)
    link_to '#', class: 'auth-trigger', data: {target: target, 'form-number'=> form_number}, &block
  end
end

