class AddJoulePurchasedAt < ActiveRecord::Migration
  def up
    add_column :users, :joule_purchased_at, :datetime
  end

  def down
    remove_column :users, :joule_purchased_at
  end
end
