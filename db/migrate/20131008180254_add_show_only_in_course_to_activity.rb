class AddShowOnlyInCourseToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :show_only_in_course, :boolean, default: false
  end
end
