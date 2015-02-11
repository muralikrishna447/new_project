class AddSignupIncentiveToUser < ActiveRecord::Migration
  def up
    add_column :users, :signup_incentive_available, :boolean, default: true
    User.update_all(signup_incentive_available: false);
  end

  def down
    remove_column :users, :signup_incentive_available
  end
end
