class AddSurveyResultsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :survey_results, :hstore
    add_hstore_index :users, :survey_results
  end
end
