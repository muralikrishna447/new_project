class AddCirculatorDiscountBoolToUser < ActiveRecord::Migration
  def change
    add_column :users, :used_circulator_discount, :boolean, default: false
  end
end
