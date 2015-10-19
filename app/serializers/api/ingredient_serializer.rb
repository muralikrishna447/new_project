class Api::IngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :image, :url, :product_url, :text_fields, :sub_activity_id

  def image
    filepicker_to_s3_url(object.image_id)
  end

  def url
    ingredient_url(object)
  end

end
