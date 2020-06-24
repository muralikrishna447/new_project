class AddPublishedToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :published, :boolean, default: false
  end
end
