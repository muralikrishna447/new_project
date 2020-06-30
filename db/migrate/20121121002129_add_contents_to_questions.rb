class AddContentsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :contents, :text, default: ''
  end
end
