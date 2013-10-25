class AddBuyBoxExtraBulletsToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :buy_box_extra_bullets, :text
  end
end
