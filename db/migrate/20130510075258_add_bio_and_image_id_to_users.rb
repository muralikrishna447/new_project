class AddBioAndImageIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_id, :text
    add_column :users, :bio, :text
  end
end
