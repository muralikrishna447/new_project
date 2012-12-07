class AddAnswerCountsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :answer_count, :integer, default: 0
    add_column :questions, :correct_answer_count, :integer, default: 0
    add_column :questions, :incorrect_answer_count, :integer, default: 0
  end
end
