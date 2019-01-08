class AddUserSettings < ActiveRecord::Migration
  def up

    create_table :user_settings do |t|
      t.string :user_id
      t.string :locale, default: nil
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
