class AddShortDescriptionToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :short_description, :text
  end
end
