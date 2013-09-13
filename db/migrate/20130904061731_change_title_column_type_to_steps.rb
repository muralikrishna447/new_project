class ChangeTitleColumnTypeToSteps < ActiveRecord::Migration

  def change
    change_column :steps, :title, :text
  end

end
