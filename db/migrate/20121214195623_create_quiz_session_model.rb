class CreateQuizSessionModel < ActiveRecord::Migration
  def change
    create_table :quiz_sessions do |t|
      t.integer :user_id, null: false
      t.integer :quiz_id, null: false
      t.boolean :completed, null: false

      t.timestamps
    end
    add_index(:quiz_sessions, [:user_id, :quiz_id], unique: true)
  end
end
