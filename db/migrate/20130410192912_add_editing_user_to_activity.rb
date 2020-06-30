class AddEditingUserToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :last_edited_by_id, :integer
  end
end
