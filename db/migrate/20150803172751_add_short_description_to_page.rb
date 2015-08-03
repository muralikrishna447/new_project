class AddShortDescriptionToPage < ActiveRecord::Migration
  def change
    add_column :pages, :short_description, :text
  end
end
