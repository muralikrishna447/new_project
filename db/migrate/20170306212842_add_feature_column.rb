class AddFeatureColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :marketplace_guides, :feature_name, :string
  end
end
