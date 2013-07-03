class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :title
      t.text :description
      t.string :slug
      t.string :status

      t.timestamps
    end
  end
end
