class Api::StepIngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :quantity, :unit, :note

  has_one :ingredient, serializer: Api::IngredientIndexSerializer

  def order
    object.ingredient_order
  end
end
