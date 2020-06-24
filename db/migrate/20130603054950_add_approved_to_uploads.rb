class AddApprovedToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :approved, :boolean, default: false
  end
end
