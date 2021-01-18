class CreateMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :menus do |t|
      t.string :name
      t.string :url
      t.integer :parent_id, index: true
      t.boolean :is_studio, default: false
      t.boolean :is_premium, default: false
      t.boolean :is_free, default: false
      t.boolean :is_not_logged, default: false
      t.integer :position

      t.timestamps
    end
  end
end
