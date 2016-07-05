class CreatePublishingSchedules < ActiveRecord::Migration
  def change
    create_table :publishing_schedules do |t|
      t.integer :activity_id
      t.datetime :publish_at
      t.timestamps
    end
  end
end

