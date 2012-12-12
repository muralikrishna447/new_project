class CreateBoxSortImage < ActiveRecord::Migration
  def change
    create_table :box_sort_images do |t|
      t.integer :question_id, null: false
      t.boolean :key_image, default: false
      t.string :key_rationale, default: ''
      t.timestamps
    end
    add_index(:box_sort_images, :question_id)
  end
end
