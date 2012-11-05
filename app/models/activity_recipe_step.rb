class ActivityRecipeStep < ActiveRecord::Base
  belongs_to :activity, touch: true, inverse_of: :activity_recipe_steps
  belongs_to :step, touch: true, inverse_of: :activity_recipe_steps

  attr_accessible :activity_id, :step_id
end

  # def create_activity_steps(recipe_ids)
  #   recipe_steps = Step.joins(:recipe).where(recipe_id: recipe_ids)
  #   recipe_steps.each do |step|
  #     steps.find_or_create_by_step_id_and_activity_id(step.id, self.id)
  #   end
  # end

  # def delete_old_steps(recipe_ids)
  #   old_step_ids = steps.joins(:step).map(&:id) - Step.joins(:recipe).where(recipe_id: recipe_ids).map(&:id)
  #   # old_steps_ids = steps.map(&:id) - Step.joins(:recipe).where(recipe_id: recipe_ids).map(&:id)
  #   pp "\n\n\n\n***********************STEP IDS: #{old_step_ids}"
  #   # steps.where(id: old_steps_ids).destroy_all
  # end
