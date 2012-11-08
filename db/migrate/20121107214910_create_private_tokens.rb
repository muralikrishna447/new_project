class CreatePrivateTokens < ActiveRecord::Migration
  def change
    create_table :private_tokens do |t|
      t.string :token, null: false
      t.timestamps
    end
  end
end
