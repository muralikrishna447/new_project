class AddUrlToQuizImage < ActiveRecord::Migration
  def change
    rename_column :quiz_images, :file_name, :filename
    add_column :quiz_images, :url, :string
  end
end
