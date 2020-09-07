class AddSingleOptInToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :opt_in, :boolean
    add_column :users, :country_code, :text
  end
end
