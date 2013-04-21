class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :footer_image

      t.timestamps
    end
  end
end
