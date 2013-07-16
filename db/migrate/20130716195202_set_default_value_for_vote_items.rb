class SetDefaultValueForVoteItems < ActiveRecord::Migration
  def change
    change_column :poll_items, :votes_count, :integer, default: 0
  end
end
