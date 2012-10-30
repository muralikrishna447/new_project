class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :recipe_id

  belongs_to :activity, touch: true, inverse_of: :steps
  belongs_to :recipe, touch: true, inverse_of: :steps

  has_many :ingredients, class_name: StepIngredient, dependent: :destroy, inverse_of: :step

  attr_accessible :title, :youtube_id, :recipe_id, :directions, :image_id,
    :ingredient_ids, :activity_id

  scope :ordered, rank(:step_order)

  default_scope { ordered }

  def title(index=nil)
    return "Step %d" % (index.to_i + 1) if self[:title].blank? and index.present?
    self[:title] || ''
  end

end

