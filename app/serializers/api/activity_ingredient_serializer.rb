class Api::ActivityIngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :quantity, :unit, :note, :sub_activity

  has_one :ingredient, serializer: Api::IngredientIndexSerializer

  def order
    object.ingredient_order
  end

  def sub_activity
    if object.sub_activity_id
      sub_activity = Activity.find(object.sub_activity_id)
      Api::ActivityIndexSerializer.new(sub_activity, root: false)
    end
  end
end
