class AddTitleToActivityRecipeSteps < ActiveRecord::Migration
  def change
    add_column :steps, :subrecipe_title, :string
  end
end
