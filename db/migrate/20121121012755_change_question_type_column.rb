class ChangeQuestionTypeColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :question_type, :string, null: true
  end
end
