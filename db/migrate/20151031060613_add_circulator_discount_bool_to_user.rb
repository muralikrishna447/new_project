class AddCirculatorDiscountBoolToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :used_circulator_discount, :boolean, default: false
  end
end
