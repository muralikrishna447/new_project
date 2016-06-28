class AddFirstPublishedAt < ActiveRecord::Migration
  def up
    add_column :activities, :first_published_at, :datetime
  end

  def down
    remove_column :activities, :first_published_at
  end
end
