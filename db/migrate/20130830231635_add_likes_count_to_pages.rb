class AddLikesCountToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :likes_count, :integer
  end
end
