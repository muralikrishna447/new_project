class AddAssignmentRecipesToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :assignment_recipes, :text
  end
end
