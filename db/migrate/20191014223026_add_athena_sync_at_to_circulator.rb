class AddAthenaSyncAtToCirculator < ActiveRecord::Migration[5.2]
  def change
    add_column :circulators, :athena_sync_at, :datetime
  end
end