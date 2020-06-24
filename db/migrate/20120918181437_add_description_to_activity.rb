class AddDescriptionToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :description, :text
    rename_column :activities, :cooked_this_count, :cooked_this
  end
end
