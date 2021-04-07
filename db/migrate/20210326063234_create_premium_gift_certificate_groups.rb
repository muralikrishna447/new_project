class CreatePremiumGiftCertificateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :premium_gift_certificate_groups do |t|
      t.string  :title, null: false
      t.integer :coupon_count, null: false
      t.integer :created_by_id, null: false
      t.boolean :coupon_creation_status, default: false
      t.timestamps
    end
  end
end
