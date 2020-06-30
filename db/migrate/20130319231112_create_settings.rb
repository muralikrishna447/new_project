class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :footer_image

      t.timestamps
    end
  end
end
