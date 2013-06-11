class ChangeCopyFormatTypeInQuizzes < ActiveRecord::Migration
  def change
    change_column :quizzes, :start_copy, :text
    change_column :quizzes, :end_copy, :text
  end
end
