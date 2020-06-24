class AddCurrentEditingUserToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :currently_editing_user, :integer
  end
end
