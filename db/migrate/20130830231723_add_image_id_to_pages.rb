class AddImageIdToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :image_id, :text
  end
end
