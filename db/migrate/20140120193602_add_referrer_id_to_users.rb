class AddReferrerIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :referrer_id, :integer
    add_column :users, :referred_from, :string
  end
end
