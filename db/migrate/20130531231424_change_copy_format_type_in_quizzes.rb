class ChangeCopyFormatTypeInQuizzes < ActiveRecord::Migration[5.2]
  def change
    change_column :quizzes, :start_copy, :text
    change_column :quizzes, :end_copy, :text
  end
end
