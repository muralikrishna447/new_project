class RemoveLayoutFromActivity < ActiveRecord::Migration[5.2]
  def change
    remove_column :activities, :layout_name
  end
end
