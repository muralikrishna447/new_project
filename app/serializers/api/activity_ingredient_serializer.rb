class Api::ActivityIngredientSerializer < ActiveModel::Serializer
  attributes :title, :quantity, :unit, :url, :product_url

  has_one :ingredient, serializer: IngredientIndexSerializer

  def url
    ingredient_url(object.ingredient)
  end

  def product_url
    object.ingredient.product_url
  end
end
