class AddNoteToActivityIngredients < ActiveRecord::Migration
  def change
    add_column :activity_ingredients, :note, :string
    add_column :step_ingredients, :note, :string
  end
end
