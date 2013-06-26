class AddAdditionalScriptToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :additional_script, :text
  end
end
