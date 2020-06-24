class AddAdditionalScriptToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :additional_script, :text
  end
end
