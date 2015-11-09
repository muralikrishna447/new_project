class AddMembershipPriceToUser < ActiveRecord::Migration
  def change
    add_column :users, :premium_membership_price, :decimal, :precision => 8, :scale => 2, default: 0
  end
end
