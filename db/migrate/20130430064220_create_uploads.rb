class CreateUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :uploads do |t|
      t.integer :activity_id
      t.integer :user_id
      t.string :recipe_name
      t.text :image_id
      t.text :notes

      t.timestamps
    end
  end
end
