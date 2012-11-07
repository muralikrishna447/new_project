class AddPublishedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :published, :boolean, default: false
  end
end
