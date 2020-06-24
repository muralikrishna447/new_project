class AddFromAweberToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :from_aweber, :boolean
  end
end
