class RemoveIsConsentDisplayedToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_consent_displayed, :boolean, default: false
  end
end
