class AddNameLastAccessedToCirculators < ActiveRecord::Migration[5.2]
  def change
    add_column :circulators, :name, :string
    add_column :circulators, :last_accessed_at, :datetime
  end
end
