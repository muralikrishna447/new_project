class AddStartAndEndCopyToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :start_copy, :string
    add_column :quizzes, :end_copy, :string
  end
end
