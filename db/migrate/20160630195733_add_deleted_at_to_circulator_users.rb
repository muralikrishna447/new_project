class AddDeletedAtToCirculatorUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :circulator_users, :deleted_at, :datetime
    add_index :circulator_users, :deleted_at
    # Inspired by https://github.com/rubysherpas/paranoia/issues/271
    execute <<-SQL.squish
      CREATE UNIQUE INDEX "index_circulator_users_unique" ON "circulator_users" ("user_id", "circulator_id", COALESCE(deleted_at, timestamp 'infinity'))
    SQL
  end
end
