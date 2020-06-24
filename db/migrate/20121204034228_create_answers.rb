class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.integer :question_id, null: false
      t.integer :user_id, null: false
      t.string :type
      t.text :contents
      t.boolean :correct, default: false
      t.timestamps
    end

    add_index :answers, [:question_id, :user_id], unique: true
  end
end
