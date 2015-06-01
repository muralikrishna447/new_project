class Api::ProfileSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :name, :bio, :image

  def image
    filepicker_to_s3_url(object.profile_image_id)
  end

end
