class AddPublishedToQuiz < ActiveRecord::Migration[5.2]
  def change
    add_column :quizzes, :published, :boolean, default: false
  end
end
