class AddTranscriptToActivitiesAndSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :transcript, :text
    add_column :steps, :transcript, :text
  end
end
