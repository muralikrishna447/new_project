class ChangeActivityOrderColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :activities, :activity_order, :integer
  end

  def down
    change_column :activities, :activity_order, :decimal
  end
end
