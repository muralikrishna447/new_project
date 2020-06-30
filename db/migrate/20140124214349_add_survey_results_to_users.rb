class AddSurveyResultsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :survey_results, :hstore
    add_hstore_index :users, :survey_results
  end
end
