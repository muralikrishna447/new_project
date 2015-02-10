class AddSignupIncentiveToUser < ActiveRecord::Migration
  def change
    add_column :users, :signup_incentive_available, :boolean, default: true
  end
end
