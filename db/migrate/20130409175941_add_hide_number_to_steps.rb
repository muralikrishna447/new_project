class AddHideNumberToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :hide_number, :boolean
  end
end
