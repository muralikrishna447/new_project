class CreateSuggestedRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :suggested_recipes do |t|
      t.string :name

      t.timestamps
    end
  end
end
