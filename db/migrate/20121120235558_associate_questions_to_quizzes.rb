class AssociateQuestionsToQuizzes < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :quiz_id, :integer
  end
end
