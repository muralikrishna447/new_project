class AddPublishedAtToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :published_at, :datetime
  end
end
