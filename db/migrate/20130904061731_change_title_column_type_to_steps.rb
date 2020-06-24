class ChangeTitleColumnTypeToSteps < ActiveRecord::Migration[5.2]

  def change
    change_column :steps, :title, :text
  end

end
