class ContentIngredientSerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :description, :url, :context

  def image
    filepicker_arbitrary_image(object.image_id, 400)
  end

  def description
    ''
  end

  def url
    ingredient_url(object)
  end

  def context
    ''
  end
end