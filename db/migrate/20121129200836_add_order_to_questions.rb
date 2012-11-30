class AddOrderToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_order, :integer
    add_index :questions, :question_order
  end
end
