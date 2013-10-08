class AddOptionalDisqusToAssemblyInclusion < ActiveRecord::Migration
  def change
    add_column :assembly_inclusions, :include_disqus, :boolean, default: false
  end
end
