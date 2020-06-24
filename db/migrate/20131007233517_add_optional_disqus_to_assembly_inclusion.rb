class AddOptionalDisqusToAssemblyInclusion < ActiveRecord::Migration[5.2]
  def change
    add_column :assembly_inclusions, :include_disqus, :boolean, default: false
  end
end
