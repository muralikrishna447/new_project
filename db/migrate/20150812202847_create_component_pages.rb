class CreateComponentPages < ActiveRecord::Migration
  def change
    create_table :component_pages do |t|
      t.integer :component_id
      t.integer :page_id
      t.integer :order
      t.timestamps
    end

    add_index :component_pages, :component_id
    add_index :component_pages, :page_id
  end
end
