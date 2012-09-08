class AddStepOrderToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :step_order, :integer
  end
end
