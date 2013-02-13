class ActivityRecipeStep < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :recipe_steps
  belongs_to :step, touch: true, inverse_of: :activity_recipe_steps

  has_one :recipe, through: :step

  attr_accessible :activity_id, :step_id, :step_order_position, :title

  delegate :title, :youtube_id, :youtube_id?, :directions, :image_id, :image_id?, :image_description, :image_description?, :ingredients, :directions, :transcript, :transcript?, :audio_clip, :audio_clip?, :audio_title, :audio_title?, to: :step

  scope :ordered, rank(:step_order)

  def sorting_title
    "#{recipe.title} - #{title}"
  end
end

