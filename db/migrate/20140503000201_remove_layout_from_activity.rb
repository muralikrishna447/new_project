class RemoveLayoutFromActivity < ActiveRecord::Migration
  def change
    remove_column :activities, :layout_name
  end
end
