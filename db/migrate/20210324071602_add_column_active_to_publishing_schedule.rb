class AddColumnActiveToPublishingSchedule < ActiveRecord::Migration[5.2]
  def change
    add_column :publishing_schedules, :active , :boolean, default: false
  end
end
