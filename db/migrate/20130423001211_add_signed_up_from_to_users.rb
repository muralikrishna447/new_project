class AddSignedUpFromToUsers < ActiveRecord::Migration
  def change
    add_column :users, :signed_up_from, :string
  end
end
