class AddFeaturedImageIdtoActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :featured_image_id, :string
  end
end
