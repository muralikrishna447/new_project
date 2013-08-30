class AddImageIdToPages < ActiveRecord::Migration
  def change
    add_column :pages, :image_id, :text
  end
end
