class Api::ProfileSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :name, :bio, :image, :meta

  def image
    filepicker_to_s3_url(object.profile_image_id)
  end

  def meta
    # In this case, scope is current_admin?
    if scope
      { email: object.email }
    end
  end

end
