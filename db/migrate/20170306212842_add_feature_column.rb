class AddFeatureColumn < ActiveRecord::Migration
  def change
    add_column :marketplace_guides, :feature_name, :string
  end
end
