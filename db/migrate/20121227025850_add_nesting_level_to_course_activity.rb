class AddNestingLevelToCourseActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :inclusions, :nesting_level, :integer, :default => "1"
  end
end
