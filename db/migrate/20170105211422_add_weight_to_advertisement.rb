class AddWeightToAdvertisement < ActiveRecord::Migration[5.2]
  def change
    add_column :advertisements, :weight, :integer, :default => 100
  end
end
