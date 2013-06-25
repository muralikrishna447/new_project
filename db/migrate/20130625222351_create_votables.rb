class CreateVotables < ActiveRecord::Migration
  def change
    create_table :votables do |t|
      t.string :title
      t.text :description
      t.string :status
      t.integer :poll_id

      t.timestamps
    end
  end
end
