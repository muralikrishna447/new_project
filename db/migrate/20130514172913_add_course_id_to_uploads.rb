class AddCourseIdToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :course_id, :integer
  end
end
