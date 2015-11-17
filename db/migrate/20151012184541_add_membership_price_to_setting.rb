class AddMembershipPriceToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :premium_membership_price, :decimal, :precision => 8, :scale => 2
  end
end
