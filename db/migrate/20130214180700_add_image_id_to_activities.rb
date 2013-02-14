class AddImageIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :image_id, :string
  end
end
