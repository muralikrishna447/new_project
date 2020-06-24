class AddBuyBoxExtraBulletsToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :buy_box_extra_bullets, :text
  end
end
