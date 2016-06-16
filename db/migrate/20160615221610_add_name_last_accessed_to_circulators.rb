class AddNameLastAccessedToCirculators < ActiveRecord::Migration
  def change
    add_column :circulators, :name, :string
    add_column :circulators, :last_accessed_at, :datetime
  end
end
