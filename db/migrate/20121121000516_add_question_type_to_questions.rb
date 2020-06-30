class AddQuestionTypeToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :question_type, :string, null: false
  end
end
