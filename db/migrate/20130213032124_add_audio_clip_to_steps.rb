class AddAudioClipToSteps < ActiveRecord::Migration
  def change
    add_column :steps, :audio_clip, :string
  end
end
