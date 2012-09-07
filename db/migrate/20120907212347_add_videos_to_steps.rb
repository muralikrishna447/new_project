class AddVideosToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :video_url, :string
  end
end
