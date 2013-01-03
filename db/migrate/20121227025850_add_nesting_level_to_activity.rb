class AddNestingLevelToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :nesting_level, :integer, :default => "1"
  end
end
