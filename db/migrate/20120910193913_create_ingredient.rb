class CreateIngredient < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :title
      t.string :product_url

      t.timestamps
    end
  end
end
