class AddUserSettings < ActiveRecord::Migration
  def up

    create_table :user_settings do |t|
      t.integer :user_id
      t.string :locale, default: nil, limit: 6
      t.string :country_iso2, default: nil, limit: 2
      t.boolean :has_viewed_turbo_intro, default: nil
      t.string  :preferred_temperature_unit, default: nil, limit: 1
      t.boolean :truffle_sauce_purchased, default: nil
      t.timestamps
    end

    add_index :user_settings, :user_id
  end

  def down
    remove_index :user_settings, :user_id
    drop_table :user_settings
  end
end
