class ChangeFacebookColumnAddTwitterColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :twitter_user_id, :string
    add_column :users, :twitter_auth_token, :string
    add_column :users, :twitter_user_name, :string
    rename_column :users, :uid, :facebook_user_id
  end
end
