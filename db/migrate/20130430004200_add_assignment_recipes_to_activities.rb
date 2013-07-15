class AddAssignmentRecipesToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :assignment_recipes, :text
  end
end
