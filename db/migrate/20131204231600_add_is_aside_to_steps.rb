class AddIsAsideToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :is_aside, :boolean
  end
end
