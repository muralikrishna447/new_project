class AddUnitToActivityIngredients < ActiveRecord::Migration[5.2]
  class ActivityIngredient < ApplicationRecord; end
  def change
    add_column :activity_ingredients, :unit, :string
    add_column :activity_ingredients, :quantity_temp, :decimal
    ActivityIngredient.all.each do |ai|
      ai.quantity_temp = ai.quantity_temp.to_i
      ai.save
    end
    remove_column :activity_ingredients, :quantity
    rename_column :activity_ingredients, :quantity_temp, :quantity
  end
end
