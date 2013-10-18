class AddImageIdToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :image_id, :text
  end
end
