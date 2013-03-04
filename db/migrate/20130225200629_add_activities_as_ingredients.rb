class AddActivitiesAsIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :sub_activity_id, :integer
  end
end
