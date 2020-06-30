class AddClosedAtToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :closed_at, :datetime
  end
end
