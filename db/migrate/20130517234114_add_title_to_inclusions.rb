class AddTitleToInclusions < ActiveRecord::Migration
  def change
    add_column :inclusions, :title, :string
  end
end
