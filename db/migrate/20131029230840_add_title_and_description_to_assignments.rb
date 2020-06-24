class AddTitleAndDescriptionToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :title, :string
    add_column :assignments, :description, :text
    add_column :assignments, :slug, :string
  end
end
