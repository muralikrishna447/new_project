class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :recipe_id

  belongs_to :activity, touch: true, inverse_of: :steps
  belongs_to :recipe, touch: true, inverse_of: :steps

  has_many :ingredients, class_name: StepIngredient, dependent: :destroy, inverse_of: :step

  attr_accessible :title, :youtube_id, :recipe_id, :directions, :image_id,
    :ingredient_ids, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  default_scope { ordered }

  def ingredient_ids=(ids)
    unless (ids = ids.map(&:to_i).select { |i| i>0 }) == (current_ids = ingredients.map(&:id))
      ids.each_with_index do |id, index|
        if current_ids.include? (id)
          ingredients.select { |b| b.id == id }.first.update_attribute(:ingredient_order_position, (index+1))
        else
          raise "can't add thing"
        end
      end
      (current_ids - ids).each { |id| ingredients.select{|b|b.id == id}.first.destroy}
    end
  end

end

