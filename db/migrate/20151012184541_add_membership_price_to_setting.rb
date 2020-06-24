class AddMembershipPriceToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :premium_membership_price, :decimal, :precision => 8, :scale => 2
  end
end
