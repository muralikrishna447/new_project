class CreateUserActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_activities do |t|
      t.integer :user_id
      t.integer :activity_id
      t.string :action

      t.timestamps
    end
  end
end
