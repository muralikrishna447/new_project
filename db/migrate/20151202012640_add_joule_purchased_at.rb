class AddJoulePurchasedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_joule_purchased_at, :datetime
    add_column :users, :joule_purchase_count, :integer, default: 0
  end
end
