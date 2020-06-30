class AddShortDescriptionToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :short_description, :text
  end
end
