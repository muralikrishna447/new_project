class AddVideoToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :video_url, :string
  end
end
