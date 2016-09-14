class AddMatchnameToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :matchname, :string
  end
end
