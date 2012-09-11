class RenameVideoUrl < ActiveRecord::Migration
  def change
    rename_column :activities, :video_url, :youtube_id
    rename_column :steps, :video_url, :youtube_id
  end
end
