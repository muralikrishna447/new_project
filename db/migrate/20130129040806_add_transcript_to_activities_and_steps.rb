class AddTranscriptToActivitiesAndSteps < ActiveRecord::Migration
  def change
    add_column :activities, :transcription, :text
    add_column :steps, :transcription, :text
  end
end
