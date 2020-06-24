class AddIncludeInGalleryToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :include_in_gallery, :boolean, default: true
  end
end
