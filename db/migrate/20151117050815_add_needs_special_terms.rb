class AddNeedsSpecialTerms < ActiveRecord::Migration
  def up
    add_column :users, :needs_special_terms, :boolean, default: false
  end

  def down
    remove_column :users, :needs_special_terms
  end
end
