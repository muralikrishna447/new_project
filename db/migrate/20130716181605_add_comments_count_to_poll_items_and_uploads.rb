class AddCommentsCountToPollItemsAndUploads < ActiveRecord::Migration
  def change
    add_column :poll_items, :comments_count, :integer
    add_column :uploads, :comments_count, :integer
  end
end
