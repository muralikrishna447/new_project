class AddFeatureColumn < ActiveRecord::Migration
  def change
    add_column :marketplace_guides, :feature_name, :string, default: 'seattle_marketplace_offers'
  end
end
