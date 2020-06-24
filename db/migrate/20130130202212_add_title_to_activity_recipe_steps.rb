class AddTitleToActivityRecipeSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :subrecipe_title, :string
  end
end
