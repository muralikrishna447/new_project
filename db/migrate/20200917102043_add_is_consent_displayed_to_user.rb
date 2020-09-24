class AddIsConsentDisplayedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_consent_displayed, :boolean, default: false
  end
end
