class RecipesHaveSteps < ActiveRecord::Migration
  def change
    add_column :steps, :recipe_id, :integer
  end
end
