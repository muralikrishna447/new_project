# TIMDISCOUNT
class AddTimFerrissIncentiveToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :timf_incentive_available, :boolean, default: true
  end

  def down
    remove_column :users, :timf_incentive_available
  end
end
