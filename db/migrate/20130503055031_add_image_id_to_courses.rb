class AddImageIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :image_id, :text
  end
end
