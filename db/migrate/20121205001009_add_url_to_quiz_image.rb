class AddUrlToQuizImage < ActiveRecord::Migration[5.2]
  def change
    rename_column :quiz_images, :file_name, :filename
    add_column :quiz_images, :url, :string
  end
end
