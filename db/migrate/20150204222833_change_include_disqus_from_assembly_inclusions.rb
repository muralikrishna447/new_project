class ChangeIncludeDisqusFromAssemblyInclusions < ActiveRecord::Migration
  def change
    change_column :assembly_inclusions, :include_disqus, :boolean, default: true
  end
end
