class CreateQuizImages < ActiveRecord::Migration
  def change
    create_table :quiz_images do |t|
      t.string :file_name
      t.string :caption

      t.timestamps
    end
  end
end
