class AddImageIdToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :image_id, :text
  end
end
