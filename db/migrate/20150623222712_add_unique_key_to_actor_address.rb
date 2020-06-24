class AddUniqueKeyToActorAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :actor_addresses, :unique_key, :string
    add_index :actor_addresses, [:actor_type, :actor_id, :unique_key], unique: true
  end
end
