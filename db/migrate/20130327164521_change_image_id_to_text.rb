class ChangeImageIdToText < ActiveRecord::Migration
  def change
    change_column :activities, :image_id, :text
    change_column :activities, :featured_image_id, :text
    change_column :steps, :image_id, :text
    change_column :videos, :image_id, :text
  end
end
