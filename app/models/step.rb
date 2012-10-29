class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :recipe_id

  belongs_to :activity, touch: true, inverse_of: :steps
  belongs_to :recipe, touch: true, inverse_of: :steps

  validates :title, presence: true

  has_many :ingredients, class_name: StepIngredient, dependent: :destroy, inverse_of: :step

  attr_accessible :title, :youtube_id, :recipe_id, :directions, :image_id,
    :ingredient_ids, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  default_scope { ordered }

end

