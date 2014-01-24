class AddSurveyResultsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :survey_results, :text
  end
end
