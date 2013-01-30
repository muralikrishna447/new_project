class AddTitleToActivityRecipeSteps < ActiveRecord::Migration
  def change
    add_column :activity_recipe_steps, :subrecipe_title, :string
  end
end
