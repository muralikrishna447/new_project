class AddPromotedOrderToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :promote_order, :integer
  end
end
