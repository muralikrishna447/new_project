class ChangeIncludeDisqusFromAssemblyInclusions < ActiveRecord::Migration[5.2]
  def change
    change_column :assembly_inclusions, :include_disqus, :boolean, default: true
  end
end
