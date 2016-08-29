class CreateAdvertisement < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.text :image
      t.text :title
      t.text :description
      t.text :button_title
      t.text :url
      t.text :campaign
      t.boolean :published, :default => false
      t.timestamps
    end
  end
end
