class Api::ActivityIngredientSerializer < ActiveModel::Serializer
  attributes :order, :title, :quantity, :unit

  has_one :ingredient, serializer: IngredientIndexSerializer

  def order
    object.ingredient_order
  end
end
