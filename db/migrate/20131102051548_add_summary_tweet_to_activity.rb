class AddSummaryTweetToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :summary_tweet, :string
  end
end
