class AddStepOrderToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :step_order, :integer
  end
end
