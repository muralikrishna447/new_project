class AddReferrerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :referrer_id, :integer
    add_column :users, :referred_from, :string
  end
end
