class AddShowOnlyInCourseToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :show_only_in_course, :boolean, default: false
  end
end
