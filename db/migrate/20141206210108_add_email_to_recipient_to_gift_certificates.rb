class AddEmailToRecipientToGiftCertificates < ActiveRecord::Migration[5.2]
  def change
    add_column :gift_certificates, :email_to_recipient, :boolean
  end
end
