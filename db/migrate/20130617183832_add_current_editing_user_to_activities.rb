class AddCurrentEditingUserToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :currently_editing_user, :integer
  end
end
