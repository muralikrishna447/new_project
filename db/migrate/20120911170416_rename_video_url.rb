class RenameVideoUrl < ActiveRecord::Migration[5.2]
  def change
    rename_column :activities, :video_url, :youtube_id
    rename_column :steps, :video_url, :youtube_id
  end
end
