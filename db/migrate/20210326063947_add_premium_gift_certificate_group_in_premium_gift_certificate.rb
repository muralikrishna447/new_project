class AddPremiumGiftCertificateGroupInPremiumGiftCertificate < ActiveRecord::Migration[5.2]
  def change
    add_column :premium_gift_certificates, :premium_gift_certificate_group_id, :integer
    add_index :premium_gift_certificates, :premium_gift_certificate_group_id, name: 'index_premium_group_id'
  end
end
