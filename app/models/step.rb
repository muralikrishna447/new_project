class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :steps

  has_many :ingredients, class_name: StepIngredient, dependent: :destroy, inverse_of: :step

  attr_accessible :title, :youtube_id, :directions, :image_id, :image_description,
    :ingredient_ids, :activity_id, :step_order_position, :transcript, :audio_clip, :audio_title, :subrecipe_title

  scope :ordered, rank(:step_order)
  scope :activity_id_not_nil, where('activity_id IS NOT NULL')

  default_scope { ordered }

  def title(index=nil)
    return "Step %d" % (index.to_i + 1) if self[:title].blank? and index.present?
    return "" if self[:title] == "-"
    self[:title] || ''
  end

  def update_ingredients(ingredient_attrs)
    reject_invalid_ingredients(ingredient_attrs)
    update_and_create_ingredients(ingredient_attrs)
    delete_old_ingredients(ingredient_attrs)
    self
  end

  private

  def reject_invalid_ingredients(ingredient_attrs)
    ingredient_attrs.select! do |ingredient_attr|
      [:title, :unit].all? do |test|
        ingredient_attr[test].present?
      end
    end
  end

  def update_and_create_ingredients(ingredient_attrs)
    ingredient_attrs.each do |ingredient_attr|
      ingredient = Ingredient.find_or_create_by_title(ingredient_attr[:title])
      step_ingredient = ingredients.find_or_create_by_ingredient_id_and_step_id(ingredient.id, self.id)
      step_ingredient.update_attributes(
        display_quantity: ingredient_attr[:display_quantity],
        unit: ingredient_attr[:unit],
        ingredient_order_position: :last
      )
      ingredient_attr[:id] = ingredient.id
    end
  end

  def delete_old_ingredients(ingredient_attrs)
    old_ingredient_ids = ingredients.map(&:ingredient_id) - ingredient_attrs.map {|i| i[:id].to_i }
    ingredients.where(ingredient_id: old_ingredient_ids).destroy_all
  end
end

