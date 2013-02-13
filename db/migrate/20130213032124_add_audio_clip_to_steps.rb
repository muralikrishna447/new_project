class AddAudioClipToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :audio_clip, :string
    add_column :steps, :audio_title, :string
  end
end
