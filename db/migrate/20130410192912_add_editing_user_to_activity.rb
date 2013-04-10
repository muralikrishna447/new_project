class AddEditingUserToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :last_edited_by_id, :integer
  end
end
