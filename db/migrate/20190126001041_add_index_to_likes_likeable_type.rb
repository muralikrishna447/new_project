class AddIndexToLikesLikeableType < ActiveRecord::Migration[5.2]
  def change
    add_index :likes, [:likeable_type, :likeable_id]
  end
end
