class AddSignedUpFromToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :signed_up_from, :string
  end
end
