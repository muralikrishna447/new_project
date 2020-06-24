class AddSummaryTweetToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :summary_tweet, :string
  end
end
