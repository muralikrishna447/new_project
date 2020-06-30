class CreateAssemblies < ActiveRecord::Migration[5.2]
  def change
    create_table :assemblies do |t|
      t.string :title
      t.text :description
      t.text :image_id
      t.string :youtube_id
      t.string :assembly_type, default: 'Assembly'
      t.string :slug
      t.integer :likes_count
      t.integer :comments_count

      t.timestamps
    end
  end
end
