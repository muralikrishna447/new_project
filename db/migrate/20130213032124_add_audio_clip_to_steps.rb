class AddAudioClipToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :audio_clip, :string
    add_column :steps, :audio_title, :string
  end
end
