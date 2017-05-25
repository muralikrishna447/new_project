class CreateGuideActivities < ActiveRecord::Migration
  def change
    create_table :guide_activities do |t|
      t.string :guide_id
      t.integer :activity_id
      t.string :guide_digest
      t.boolean :autoupdate, default: true
      t.timestamps
    end

    add_index :guide_activities, :guide_id
    add_index :guide_activities, :activity_id

  end
end
