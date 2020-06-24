class CreateFollowerships < ActiveRecord::Migration[5.2]
  def change
    create_table :followerships do |t|
      t.integer :user_id
      t.integer :follower_id

      t.timestamps
    end
    add_index :followerships, :user_id
    add_index :followerships, :follower_id
  end
end
