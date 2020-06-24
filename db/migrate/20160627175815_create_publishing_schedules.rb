class CreatePublishingSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_schedules do |t|
      t.integer :activity_id
      t.datetime :publish_at
      t.timestamps
    end
  end
end

