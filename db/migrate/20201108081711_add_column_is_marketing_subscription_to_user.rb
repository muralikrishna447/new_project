class AddColumnIsMarketingSubscriptionToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :marketing_mail_status, :integer, :default => 0
  end
end
