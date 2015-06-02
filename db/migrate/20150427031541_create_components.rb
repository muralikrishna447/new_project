class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.string :slug
      t.string :component_type
      t.string :mode
      t.column :metadata, :hstore

      t.timestamps
    end
  end
end
