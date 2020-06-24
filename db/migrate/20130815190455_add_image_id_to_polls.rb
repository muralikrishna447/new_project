class AddImageIdToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :image_id, :text
  end
end
