class AddContentsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :contents, :text, default: ''
  end
end
