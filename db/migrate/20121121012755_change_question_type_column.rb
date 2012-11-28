class ChangeQuestionTypeColumn < ActiveRecord::Migration
  def change
    change_column :questions, :question_type, :string, null: true
  end
end
