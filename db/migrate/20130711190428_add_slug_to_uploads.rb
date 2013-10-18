class AddSlugToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :slug, :string
  end
end
