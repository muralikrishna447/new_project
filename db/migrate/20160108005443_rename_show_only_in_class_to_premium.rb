class RenameShowOnlyInClassToPremium < ActiveRecord::Migration[5.2]
  def change
  	rename_column :activities, :show_only_in_course, :premium
  end
end
