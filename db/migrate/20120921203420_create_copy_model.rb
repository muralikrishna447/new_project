class CreateCopyModel < ActiveRecord::Migration
  def change
    create_table :copy do |t|
      t.string :location
      t.text :markdown
      t.timestamps
    end
  end
end
