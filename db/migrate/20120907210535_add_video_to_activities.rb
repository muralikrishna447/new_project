class AddVideoToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :video_url, :string
  end
end
