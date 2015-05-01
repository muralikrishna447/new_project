class AddVimeo < ActiveRecord::Migration
  def change
    add_column :activities, :vimeo_id, :string
    add_column :assemblies, :vimeo_id, :string
    add_column :steps, :vimeo_id, :string
    add_column :ingredients, :vimeo_id, :string
  end
end
