class AddActivitiesAsIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :sub_activity_id, :integer
  end
end
