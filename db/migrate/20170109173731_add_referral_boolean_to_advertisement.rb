class AddReferralBooleanToAdvertisement < ActiveRecord::Migration[5.2]
  def change
    add_column :advertisements, :add_referral_code, :boolean, default: false
  end
end
