class AddAssemblyIdToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :assembly_id, :integer
  end
end
