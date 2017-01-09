class AddReferralBooleanToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :add_referral_code, :boolean, default: false
  end
end
