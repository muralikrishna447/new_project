class AddLikesCountToPages < ActiveRecord::Migration
  def change
    add_column :pages, :likes_count, :integer
  end
end
