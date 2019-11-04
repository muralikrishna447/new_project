class AddAthenaSyncAtToCirculator < ActiveRecord::Migration
  def change
    add_column :circulators, :athena_sync_at, :datetime
  end
end