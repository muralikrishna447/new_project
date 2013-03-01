class AddFeaturedImageIdtoActivities < ActiveRecord::Migration
  def change
    add_column :activities, :featured_image_id, :string
  end
end
