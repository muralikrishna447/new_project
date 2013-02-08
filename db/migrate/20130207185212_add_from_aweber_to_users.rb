class AddFromAweberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :from_aweber, :boolean
  end
end
