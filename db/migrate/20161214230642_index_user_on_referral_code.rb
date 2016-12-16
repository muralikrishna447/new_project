class IndexUserOnReferralCode < ActiveRecord::Migration
  def change
    add_index(:users, :referral_code)
  end
end
