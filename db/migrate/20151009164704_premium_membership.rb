class PremiumMembership < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :premium_member, :boolean, default: false
    add_column :users, :premium_membership_created_at, :datetime
  end
end
