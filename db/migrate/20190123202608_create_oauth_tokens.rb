class CreateOauthTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_tokens do |t|
      t.integer :user_id
      t.string :service
      t.string :token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.timestamps
    end
  end
end
