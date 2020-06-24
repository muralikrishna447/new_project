class AddUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.string :locale, default: nil, limit: 10
      t.string :country_iso2, default: nil, limit: 2
      t.boolean :has_viewed_turbo_intro, default: nil
      t.string  :preferred_temperature_unit, default: nil, limit: 1
      t.boolean :has_purchased_truffle_sauce, default: nil
      t.timestamps
    end
    add_index :user_settings, :user_id, :unique => true
  end
end
