class AddIsAsideToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :is_aside, :boolean
  end
end
