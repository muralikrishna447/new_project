class ChangeFacebookColumnAddTwitterColumn < ActiveRecord::Migration
  def change
    add_column :users, :twitter_user_id, :string
    add_column :users, :twitter_auth_token, :string
    add_column :users, :twitter_user_name, :string
    rename_column :users, :uid, :facebook_user_id
  end
end
