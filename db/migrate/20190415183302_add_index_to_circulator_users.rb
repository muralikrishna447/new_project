class AddIndexToCirculatorUsers < ActiveRecord::Migration
  def change
    add_index(:circulator_users, :circulator_id)
  end
end