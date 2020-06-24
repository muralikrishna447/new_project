class AddStartAndEndCopyToQuizzes < ActiveRecord::Migration[5.2]
  def change
    add_column :quizzes, :start_copy, :string
    add_column :quizzes, :end_copy, :string
  end
end
