class CreateOrderSortImages < ActiveRecord::Migration
  def change
    create_table :order_sort_images do |t|
      t.integer :question_id
      t.timestamps
    end
  end
end
