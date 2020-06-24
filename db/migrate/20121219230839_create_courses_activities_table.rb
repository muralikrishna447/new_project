class CreateCoursesActivitiesTable < ActiveRecord::Migration[5.2]
  def up
    create_table :inclusions do |t|
      t.references :course
      t.references :activity
      t.decimal    :activity_order
    end
    add_index :inclusions, [:activity_id, :course_id]
    add_index :inclusions, [:course_id, :activity_id]
  end

  def down
  end
end
