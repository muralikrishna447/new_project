class AddPrimaryPathToPages < ActiveRecord::Migration
  def change
    add_column :pages, :primary_path, :string
  end
end
