class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :youtube_id
      t.string :title
      t.string :description
      t.boolean :featured
      t.boolean :filmstrip

      t.timestamps
    end
  end
end
