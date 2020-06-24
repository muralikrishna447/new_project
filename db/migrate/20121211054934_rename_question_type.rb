class RenameQuestionType < ActiveRecord::Migration[5.2]
  def change
    rename_column :questions, :question_type, :type
  end
end
