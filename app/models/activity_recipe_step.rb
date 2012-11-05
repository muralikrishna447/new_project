class ActivityRecipeStep < ActiveRecord::Base
  belongs_to :activity, touch: true, inverse_of: :recipe_steps
  belongs_to :step, touch: true, inverse_of: :activity_recipe_steps

  attr_accessible :activity_id, :step_id
  delegate :title, :youtube_id, :directions, :image_id, :ingredient_ids, to: :step
end

