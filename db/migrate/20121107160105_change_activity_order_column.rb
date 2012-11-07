class ChangeActivityOrderColumn < ActiveRecord::Migration
  def up
    change_column :activities, :activity_order, :integer
  end

  def down
    change_column :activities, :activity_order, :decimal
  end
end
