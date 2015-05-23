class CreateActorAddresses < ActiveRecord::Migration
  def change
    # each row represents
    create_table :actor_addresses do |t|
      t.string :actor_type, null: false
      t.integer :actor_id, null: false # mapped to hashId strings in outgoing stuff

      t.string :address_type, null: false
      t.string :address_id, uniqueness: true # generate as hashId of the sequence number

      t.integer :sequence, default: 0, null: false
      t.string :ip_address

      t.string :status, default: 'something'
      t.integer :issued_at
      t.integer :expires_at

      t.timestamps
    end

    add_index :actor_addresses, [:actor_id]
    add_index :actor_addresses, [:address_type, :address_id], unique: true
  end
end
