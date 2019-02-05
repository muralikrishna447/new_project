class AddIndexToLikesLikeableType < ActiveRecord::Migration
  def change
    add_index :likes, [:likeable_type, :likeable_id]
  end
end
