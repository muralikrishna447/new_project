class AddImageIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :image_id, :string
  end
end
