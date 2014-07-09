class AddGlobalMessageToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :global_message, :text
    add_column :settings, :global_message_active, :boolean, default: false
  end
end
