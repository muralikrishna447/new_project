class AddChefTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :chef_type, :string, null: false, default: ''
  end
end
