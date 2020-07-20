class AddPromotedOrderToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :promote_order, :integer
  end
end
