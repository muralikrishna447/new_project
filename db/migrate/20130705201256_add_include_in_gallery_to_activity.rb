class AddIncludeInGalleryToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :include_in_gallery, :boolean, default: true
  end
end
