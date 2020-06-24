class AddIndexToCirculatorUsers < ActiveRecord::Migration[5.2]
  def change
    add_index(:circulator_users, :circulator_id)
  end
end