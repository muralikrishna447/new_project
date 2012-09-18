class AddDirectionsToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :directions, :text
  end
end
