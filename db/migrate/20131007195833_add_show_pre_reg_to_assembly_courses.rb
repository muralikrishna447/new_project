class AddShowPreRegToAssemblyCourses < ActiveRecord::Migration
  def change
    add_column :assemblies, :show_prereg_page_in_index, :boolean, default: false
  end
end
