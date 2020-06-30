class AddNoteToActivityIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_ingredients, :note, :string
    add_column :step_ingredients, :note, :string
  end
end
