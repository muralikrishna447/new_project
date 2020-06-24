class RenameCopyMarkdown < ActiveRecord::Migration[5.2]
  def change
    rename_column :copies, :markdown, :copy
  end
end
