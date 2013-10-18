class AddGroupTypeAndGroupNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :group_type, :string
    add_column :events, :group_name, :text
  end
end
