class AddIndexToAppleUserId < ActiveRecord::Migration[5.2]
  def change
    add_index(:users, :apple_user_id)
  end
end

