class AddCommentsCountToPollItemsAndUploads < ActiveRecord::Migration
  def change
    add_column :poll_items, :comments_count, :integer, default: 0
    add_column :uploads, :comments_count, :integer, default: 0
  end
end
