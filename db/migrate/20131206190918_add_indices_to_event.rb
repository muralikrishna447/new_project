class AddIndicesToEvent < ActiveRecord::Migration
  def change
    add_index(:events, :user_id)
    add_index(:events, :action)
    add_index(:events, :trackable_type)
    add_index(:events, [:trackable_type, :trackable_id])
    add_index(:events, [:action, :trackable_type, :trackable_id])
    add_index(:events, :group_type)
    add_index(:events, :group_name)

  end
end
