class AddPriceToAssembly < ActiveRecord::Migration
  def change
    add_column :assemblies, :price, :decimal, :precision => 8, :scale => 2
  end
end
