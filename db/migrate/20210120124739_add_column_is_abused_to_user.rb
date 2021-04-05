class AddColumnIsAbusedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_abused, :boolean, default: false
  end
end
