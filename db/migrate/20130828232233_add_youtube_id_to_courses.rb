class AddYoutubeIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :youtube_id, :string
  end
end
