class RemoveTitleFromQuestions < ActiveRecord::Migration[5.2]
  def change
    remove_column :questions, :title
  end
end
