class AddPrimaryPathToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :primary_path, :string
  end
end
