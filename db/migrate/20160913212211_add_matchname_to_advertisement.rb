class AddMatchnameToAdvertisement < ActiveRecord::Migration[5.2]
  def change
    add_column :advertisements, :matchname, :string
  end
end
