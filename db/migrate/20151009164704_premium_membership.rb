class PremiumMembership < ActiveRecord::Migration
  def change
    add_column :users, :premium_member, :boolean, default: false
    add_column :users, :premium_membership_created_at, :datetime
  end
end
