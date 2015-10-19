class Api::ActivityIngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :quantity, :unit, :note

  has_one :ingredient, serializer: Api::IngredientIndexSerializer
  has_one :activity, serializer: Api::ActivityIndexSerializer

  def order
    object.ingredient_order
  end
end
