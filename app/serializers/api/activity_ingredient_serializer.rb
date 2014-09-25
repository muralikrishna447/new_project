class Api::ActivityIngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :quantity, :unit

  has_one :ingredient, serializer: Api::IngredientIndexSerializer

  def order
    object.ingredient_order
  end
end
