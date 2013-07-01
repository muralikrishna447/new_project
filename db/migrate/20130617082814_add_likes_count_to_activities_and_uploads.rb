class AddLikesCountToActivitiesAndUploads < ActiveRecord::Migration
  def change
    add_column :activities, :likes_count, :integer
    add_column :uploads, :likes_count, :integer
  end
end
