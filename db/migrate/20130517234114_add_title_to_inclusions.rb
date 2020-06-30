class AddTitleToInclusions < ActiveRecord::Migration[5.2]
  def change
    add_column :inclusions, :title, :string
  end
end
