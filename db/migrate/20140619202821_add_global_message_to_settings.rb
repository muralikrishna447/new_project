class AddGlobalMessageToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :global_message, :text
    add_column :settings, :global_message_active, :boolean, default: false
  end
end
