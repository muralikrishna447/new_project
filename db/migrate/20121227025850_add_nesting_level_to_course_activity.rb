class AddNestingLevelToCourseActivity < ActiveRecord::Migration
  def change
    add_column :inclusions, :nesting_level, :integer, :default => "1"
  end
end
