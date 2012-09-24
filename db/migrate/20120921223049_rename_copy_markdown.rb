class RenameCopyMarkdown < ActiveRecord::Migration
  def change
    rename_column :copies, :markdown, :copy
  end
end
