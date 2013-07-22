class CreateAssemblies < ActiveRecord::Migration
  def change
    create_table :assemblies do |t|
      t.string :title
      t.text :description
      t.text :image_id
      t.string :youtube_id

      t.timestamps
    end
  end
end
