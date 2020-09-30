class AddColunFeatureImageTagToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :featured_image_tag, :string
  end
end
