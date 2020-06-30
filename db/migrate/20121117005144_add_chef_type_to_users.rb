class AddChefTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :chef_type, :string, null: false, default: ''
  end
end
