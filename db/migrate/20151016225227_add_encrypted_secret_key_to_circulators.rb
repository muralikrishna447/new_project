class AddEncryptedSecretKeyToCirculators < ActiveRecord::Migration[5.2]
  def change
    add_column :circulators, :encrypted_secret_key, :string, :limit => 64
  end
end
