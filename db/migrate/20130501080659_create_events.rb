class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :action
      t.integer :trackable_id
      t.string :trackable_type

      t.timestamps
    end
  end
end
