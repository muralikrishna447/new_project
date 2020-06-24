class IndexUserOnReferralCode < ActiveRecord::Migration[5.2]
  def change
    add_index(:users, :referral_code)
  end
end
