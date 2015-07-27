class Api::AssemblyIndexSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :image, :url, :price, :description

  def image
    filepicker_to_s3_url(object.image_id)
  end

  def url
    assembly_type_url(object)
  end

end
