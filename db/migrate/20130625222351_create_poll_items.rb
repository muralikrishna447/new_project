class CreatePollItems < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_items do |t|
      t.string :title
      t.text :description
      t.string :status
      t.integer :poll_id
      t.integer :votes_count

      t.timestamps
    end
  end
end
