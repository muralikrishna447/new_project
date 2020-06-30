class AddSlugToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :slug, :string
  end
end
