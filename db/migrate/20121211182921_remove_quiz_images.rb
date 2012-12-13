class RemoveQuizImages < ActiveRecord::Migration
  def change
    drop_table :quiz_images
  end
end
