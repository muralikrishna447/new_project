class AddFollowedUpToGiftCertificate < ActiveRecord::Migration[5.2]
  def change
    add_column :gift_certificates, :followed_up, :boolean, default: false
  end
end
