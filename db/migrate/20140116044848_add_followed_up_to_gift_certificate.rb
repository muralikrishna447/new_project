class AddFollowedUpToGiftCertificate < ActiveRecord::Migration
  def change
    add_column :gift_certificates, :followed_up, :boolean, default: false
  end
end
