class AddUniqueConstraintToCirculators < ActiveRecord::Migration
  def change
    add_column :circulators, :deleted_at, :datetime
    add_index :circulators, :deleted_at
    # Inspired by https://github.com/rubysherpas/paranoia/issues/271
    execute <<-SQL.squish
      CREATE UNIQUE INDEX "index_circulators_on_circulator_id" ON "circulators" ("circulator_id", COALESCE(deleted_at, timestamp 'infinity'))
    SQL
  end
end
