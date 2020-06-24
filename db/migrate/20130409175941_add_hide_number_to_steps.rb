class AddHideNumberToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :hide_number, :boolean
  end
end
