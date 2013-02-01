class AddShortDescriptionToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :short_description, :string
  end
end
