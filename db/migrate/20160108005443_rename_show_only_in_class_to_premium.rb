class RenameShowOnlyInClassToPremium < ActiveRecord::Migration
  def change
  	rename_column :activities, :show_only_in_course, :premium
  end
end
