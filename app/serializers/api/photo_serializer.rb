class Api::PhotoSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :description, :image, :url, :likes_count

  def description
    object.notes
  end

  def image
    filepicker_to_s3_url(object.image_id)
  end

  def url
    upload_url(object)
  end

end
