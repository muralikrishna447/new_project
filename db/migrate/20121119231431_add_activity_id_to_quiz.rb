class AddActivityIdToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :activity_id, :integer
    add_index :quizzes, :activity_id
  end
end
