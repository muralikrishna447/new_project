class AddClosedAtToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :closed_at, :datetime
  end
end
