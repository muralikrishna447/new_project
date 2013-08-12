class SetDefaultValueForVoteItems < ActiveRecord::Migration
  def up
    change_column :poll_items, :votes_count, :integer, default: 0
  end

  def down
    change_column :poll_items, :votes_count, :integer
  end  
end
