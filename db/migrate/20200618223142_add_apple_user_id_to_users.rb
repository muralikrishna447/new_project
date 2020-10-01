class AddAppleUserIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :apple_user_id, :string
  end
end
