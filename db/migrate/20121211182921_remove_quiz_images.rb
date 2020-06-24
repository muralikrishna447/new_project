class RemoveQuizImages < ActiveRecord::Migration[5.2]
  def change
    drop_table :quiz_images
  end
end
