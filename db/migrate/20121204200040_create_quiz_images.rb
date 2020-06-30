class CreateQuizImages < ActiveRecord::Migration[5.2]
  def change
    create_table :quiz_images do |t|
      t.string :file_name
      t.string :caption
      t.integer :quiz_id

      t.timestamps
    end
  end
end
