class RenameQuestionType < ActiveRecord::Migration
  def change
    rename_column :questions, :question_type, :type
  end
end
