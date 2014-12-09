class AddEmailToRecipientToGiftCertificates < ActiveRecord::Migration
  def change
    add_column :gift_certificates, :email_to_recipient, :boolean
  end
end
