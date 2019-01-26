class AddIndexToLikesLikeableType < ActiveRecord::Migration
  def change
    add_index :likes, :likeable_type, :unique => false
    add_index :likes, :likeable_id, :unique => false
  end
end
