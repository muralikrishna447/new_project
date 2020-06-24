class AddVideosToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :video_url, :string
  end
end
