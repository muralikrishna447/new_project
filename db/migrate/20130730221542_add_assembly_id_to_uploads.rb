class AddAssemblyIdToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :assembly_id, :integer
  end
end
