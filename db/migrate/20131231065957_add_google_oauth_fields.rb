class AddGoogleOauthFields < ActiveRecord::Migration
  def change
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_access_token, :string
    add_column :users, :google_user_id, :string
  end
end
