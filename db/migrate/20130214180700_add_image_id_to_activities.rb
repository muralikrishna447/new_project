class AddImageIdToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :image_id, :string
  end
end
