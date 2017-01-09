class AddWeightToAdvertisement < ActiveRecord::Migration
  def change
    add_column :advertisements, :weight, :integer, :default => 100
  end
end
