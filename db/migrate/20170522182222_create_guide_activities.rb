class CreateGuideActivities < ActiveRecord::Migration
  def change
    create_table :guide_activities do |t|
      t.string :guide_id
      t.integer :activity_id
      t.boolean :autoupdate, default: true
      t.timestamps
    end
  end
end
