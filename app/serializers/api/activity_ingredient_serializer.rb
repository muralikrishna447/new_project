class Api::ActivityIngredientSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :quantity, :unit, :note, :sub_activity

  has_one :ingredient, serializer: Api::IngredientIndexSerializer

  def title
    CGI.unescapeHTML(object.title.to_s)
  end

  def order
    object.ingredient_order
  end

  def sub_activity
    if object.sub_activity_id
      sub_activity = Activity.find_by_id(object.sub_activity_id)
      unless sub_activity.present?
        activity_name = object.step&.activity&.name
        Rails.logger.warn("#{object.title} recipe is attached as an ingredient in #{activity_name} recipe which is no longer available")
      end
      Api::ActivityIndexSerializer.new(sub_activity, root: false)
    end
  end
end
