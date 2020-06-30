class AddQuoteAndWebsiteToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :website, :string, default: ''
    add_column :users, :quote, :text, default: ''
  end
end
