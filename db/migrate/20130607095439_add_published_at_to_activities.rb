class AddPublishedAtToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :published_at, :datetime
  end
end
