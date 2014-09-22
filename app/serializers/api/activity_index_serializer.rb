class Api::ActivityIndexSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :description, :image, :url, :likes_count, :published

  def image
    filepicker_to_s3_url(object.featured_image)
  end

  def url
    activity_url(object)
  end

end
