class Api::IngredientIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :url, :product_url

  def image
    filepicker_to_s3_url(object.image_id)
  end

  def url
    ingredient_url(object)
  end
end
