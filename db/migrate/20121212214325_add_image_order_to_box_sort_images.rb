class AddImageOrderToBoxSortImages < ActiveRecord::Migration[5.2]
  def change
    add_column :box_sort_images, :image_order, :integer

    add_index :box_sort_images, :image_order
  end
end
