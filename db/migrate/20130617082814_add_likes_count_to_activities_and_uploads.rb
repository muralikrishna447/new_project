class AddLikesCountToActivitiesAndUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :likes_count, :integer
    add_column :uploads, :likes_count, :integer
  end
end
