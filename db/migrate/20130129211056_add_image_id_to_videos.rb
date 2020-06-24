class AddImageIdToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :image_id, :string
  end
end
