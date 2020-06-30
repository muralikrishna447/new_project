class SetDefaultValueForVoteItems < ActiveRecord::Migration[5.2]
  def up
    change_column :poll_items, :votes_count, :integer, default: 0
  end

  def down
    change_column :poll_items, :votes_count, :integer
  end  
end
